module NetworkDesign
  # Chooses the equipment quality tier for each quotation profile.
  #
  # The catalog rates every item with a power (tier) from 1 to 3. Each
  # profile states which tier it prefers and which ones it accepts as a
  # fallback when the preferred tier is out of stock.
  class EquipmentTierSelector
    PROFILES = {
      economic: [1, 2, 3],
      standard: [2, 3, 1],
      optimal: [3, 2, 1]
    }.freeze

    NO_TIER = 0

    # available: [equipment_type, power] pairs present in the catalog.
    def initialize(available)
      @stock = available.each_with_object({}) do |(etype, power), stock|
        (stock[etype.to_s] ||= []) << power.to_i
      end
    end

    def available?(etype)
      @stock.key?(etype.to_s)
    end

    # Preferred tier in stock for the profile, or NO_TIER when the catalog
    # has nothing of that type.
    def tier(etype, profile)
      preferences = PROFILES.fetch(profile) { raise ArgumentError, "unknown quotation profile #{profile.inspect}" }
      stock = @stock.fetch(etype.to_s, [])

      preferences.find { |power| stock.include?(power) } || NO_TIER
    end
  end
end
