require_relative '../../service_test_helper'
require 'network_design/equipment_tier_selector'

module NetworkDesign
  class EquipmentTierSelectorTest < Minitest::Test
    def selector
      EquipmentTierSelector.new([['Switch', 1], ['Switch', 2], ['Switch', 3], ['Router', 2], ['AP', 1], ['AP', 3]])
    end

    def test_each_profile_takes_its_preferred_tier_when_in_stock
      assert_equal 1, selector.tier('Switch', :economic)
      assert_equal 2, selector.tier('Switch', :standard)
      assert_equal 3, selector.tier('Switch', :optimal)
    end

    def test_profiles_fall_back_in_their_own_order
      assert_equal 2, selector.tier('Router', :economic)
      assert_equal 2, selector.tier('Router', :optimal)
      assert_equal 3, selector.tier('AP', :standard), 'standard prefers 2, then 3, then 1'
    end

    def test_missing_equipment_type
      refute selector.available?('Rack')
      assert_equal EquipmentTierSelector::NO_TIER, selector.tier('Rack', :optimal)
    end

    def test_accepts_symbols_and_string_powers
      tiered = EquipmentTierSelector.new([[:Toma, '3']])

      assert tiered.available?('Toma')
      assert_equal 3, tiered.tier(:Toma, :economic)
    end

    def test_unknown_profile
      error = assert_raises(ArgumentError) { selector.tier('Switch', :premium) }
      assert_equal 'unknown quotation profile :premium', error.message
    end
  end
end
