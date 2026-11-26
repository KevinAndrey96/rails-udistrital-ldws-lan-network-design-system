require_relative '../../service_test_helper'
require 'network_design/vlsm_planner'

module NetworkDesign
  class VlsmPlannerTest < Minitest::Test
    def plan(demands, base = '192.168.1.0')
      VlsmPlanner.new(base).plan(demands)
    end

    def test_allocates_largest_demand_first_on_aligned_blocks
      result = plan('it' => 10, 'ventas' => 50, 'gerencia' => 20)

      assert_equal %w(ventas gerencia it), result.allocations.map(&:name)
      assert_equal %w(192.168.1.0/26 192.168.1.64/27 192.168.1.96/28), result.allocations.map(&:cidr)
    end

    def test_report_matches_the_contract_used_by_the_pdf_views
      report = plan('ventas' => 50).to_report

      assert_equal({ 'Host' => '192.168.1.0', 'Mascara' => '255.255.255.192' }, report['Datos'])
      assert_equal(
        {
          'size' => 62, 'subnet' => '192.168.1.0', 'cidr' => 26, 'mask' => '255.255.255.192',
          'firstHost' => '192.168.1.1', 'lastHost' => '192.168.1.62', 'broadcast' => '192.168.1.63'
        },
        report['ventas']
      )
    end

    def test_block_sizes_at_power_of_two_boundaries
      [[0, 30], [1, 30], [2, 30], [3, 29], [6, 29], [7, 28], [62, 26], [63, 25], [254, 24], [255, 23]].each do |hosts, prefix|
        assert_equal prefix, VlsmPlanner.prefix_for(hosts), "#{hosts} hosts"
      end
    end

    def test_allocations_never_overlap_and_stay_contiguous
      result = plan('a' => 120, 'b' => 60, 'c' => 30, 'd' => 12, 'e' => 2, 'f' => 2)

      result.allocations.each_cons(2) do |left, right|
        assert_equal left.broadcast + 1, right.network
      end
      assert_equal '255.255.255.0', VlsmPlanner.format_address(result.summary_mask)
    end

    def test_demands_beyond_a_slash_24_spill_into_the_next_octets
      result = plan('campus' => 500, 'lab' => 100)

      assert_equal %w(192.168.2.0/23 192.168.4.0/25), result.allocations.map(&:cidr)
      assert_equal 21, result.summary_prefix
    end

    def test_ties_are_broken_by_name_for_deterministic_plans
      assert_equal %w(alpha beta), plan('beta' => 10, 'alpha' => 10).allocations.map(&:name)
    end

    def test_projected_hosts_applies_growth_with_integer_arithmetic
      assert_equal 57, VlsmPlanner.projected_hosts(50, 15)
      assert_equal 50, VlsmPlanner.projected_hosts(50, nil)
    end

    def test_utilization_is_requested_over_allocated_addresses
      assert_in_delta 50.0 / 64, plan('ventas' => 50).utilization
      assert_equal 0.0, plan({}).utilization
    end

    def test_empty_plan_reports_a_host_route
      assert_equal({ 'Host' => '192.168.1.0', 'Mascara' => '255.255.255.255' }, plan({}).to_report['Datos'])
    end

    def test_rejects_invalid_base_addresses
      ['192.168.1', '192.168.1.256', 'a.b.c.d', '', nil, '1.2.3.4.5'].each do |base|
        error = assert_raises(VlsmPlanner::AddressingError) { VlsmPlanner.new(base) }
        assert_match(/invalid ipv4 address/, error.message)
      end
    end

    def test_raises_when_the_address_space_is_exhausted
      error = assert_raises(VlsmPlanner::AddressingError) do
        plan({ 'big' => 100, 'more' => 100, 'extra' => 10 }, '255.255.255.0')
      end
      assert_equal 'subnet extra: address space exhausted', error.message
    end

    def test_the_last_block_may_end_exactly_at_the_top_of_the_address_space
      assert_equal '255.255.255.255', plan({ 'big' => 100, 'more' => 100 }, '255.255.255.0').to_report['more']['broadcast']
    end

    def test_rejects_negative_demands
      assert_raises(VlsmPlanner::AddressingError) { plan('broken' => -1) }
    end
  end
end
