module NetworkDesign
  # Variable Length Subnet Masking (VLSM) planner for IPv4.
  #
  # Each demand (subnet name => required hosts) receives the smallest block
  # that fits its hosts plus the network and broadcast addresses. Blocks are
  # handed out largest first, starting at the base address, and every block
  # is aligned to its own size, so allocations never overlap and the address
  # space stays contiguous.
  #
  #   plan = NetworkDesign::VlsmPlanner.new('192.168.1.0').plan('ventas' => 50, 'it' => 10)
  #   plan.allocations.first.cidr # => "192.168.1.0/26"
  class VlsmPlanner
    class AddressingError < StandardError; end

    ADDRESS_SPACE = 2**32
    # /30 is the smallest block with usable hosts (2).
    MAX_PREFIX = 30

    Allocation = Struct.new(:name, :requested_hosts, :network, :prefix) do
      def block_size
        2**(32 - prefix)
      end

      def usable_hosts
        block_size - 2
      end

      def broadcast
        network + block_size - 1
      end

      def mask
        VlsmPlanner.prefix_mask(prefix)
      end

      def cidr
        "#{VlsmPlanner.format_address(network)}/#{prefix}"
      end

      def to_report
        {
          'size' => usable_hosts,
          'subnet' => VlsmPlanner.format_address(network),
          'cidr' => prefix,
          'mask' => VlsmPlanner.format_address(mask),
          'firstHost' => VlsmPlanner.format_address(network + 1),
          'lastHost' => VlsmPlanner.format_address(broadcast - 1),
          'broadcast' => VlsmPlanner.format_address(broadcast)
        }
      end
    end

    Plan = Struct.new(:base_address, :allocations) do
      # Shortest prefix that contains the base address and every allocation:
      # the route a core router would advertise for the whole design.
      def summary_prefix
        return 32 if allocations.empty?

        last_address = allocations.map(&:broadcast).max

        32 - (base_address ^ last_address).bit_length
      end

      def summary_mask
        VlsmPlanner.prefix_mask(summary_prefix)
      end

      def utilization
        allocated = allocations.map(&:block_size).reduce(0, :+)
        return 0.0 if allocated.zero?

        allocations.map(&:requested_hosts).reduce(0, :+).fdiv(allocated)
      end

      # Hash shape the PDF reports were written against:
      # "Datos" => { "Host", "Mascara" } plus one entry per subnet name.
      def to_report
        report = {
          'Datos' => {
            'Host' => VlsmPlanner.format_address(base_address),
            'Mascara' => VlsmPlanner.format_address(summary_mask)
          }
        }
        allocations.each { |allocation| report[allocation.name.to_s] = allocation.to_report }

        report
      end
    end

    # Host demand after applying a growth (scalability) percentage, using the
    # same integer arithmetic as the original LDWS reports.
    def self.projected_hosts(hosts, growth_percent)
      hosts.to_i + (hosts.to_i * growth_percent.to_i / 100)
    end

    def self.parse_address(text)
      octets = text.to_s.strip.split('.', -1)
      unless octets.size == 4 && octets.all? { |octet| octet =~ /\A\d{1,3}\z/ && octet.to_i <= 255 }
        raise AddressingError, "invalid ipv4 address #{text.inspect}"
      end

      octets.reduce(0) { |address, octet| (address << 8) | octet.to_i }
    end

    def self.format_address(address)
      [24, 16, 8, 0].map { |shift| (address >> shift) & 0xFF }.join('.')
    end

    def self.prefix_mask(prefix)
      (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF
    end

    def self.prefix_for(hosts)
      raise AddressingError, "negative host count #{hosts}" if hosts < 0

      host_bits = [(hosts + 1).bit_length, 32 - MAX_PREFIX].max
      raise AddressingError, "#{hosts} hosts exceed the ipv4 address space" if host_bits > 32

      32 - host_bits
    end

    def initialize(base_address)
      @base_address = self.class.parse_address(base_address)
    end

    # demands: Hash or array of [name, hosts] pairs. Ties on size are broken
    # by name so the same input always yields the same plan.
    def plan(demands)
      cursor = @base_address
      ordered = demands.map { |name, hosts| [name, hosts.to_i] }
                       .sort_by { |name, hosts| [-hosts, name.to_s] }
      allocations = ordered.map do |name, hosts|
        prefix = self.class.prefix_for(hosts)
        block_size = 2**(32 - prefix)
        network = align(cursor, block_size)
        raise AddressingError, "subnet #{name}: address space exhausted" if network + block_size > ADDRESS_SPACE

        cursor = network + block_size
        Allocation.new(name, hosts, network, prefix)
      end

      Plan.new(@base_address, allocations)
    end

    private

    def align(address, block_size)
      remainder = address % block_size
      return address if remainder.zero?

      address + block_size - remainder
    end
  end
end
