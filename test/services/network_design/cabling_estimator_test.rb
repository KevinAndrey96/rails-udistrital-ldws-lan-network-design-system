require_relative '../../service_test_helper'
require 'network_design/cabling_estimator'

module NetworkDesign
  class CablingEstimatorTest < Minitest::Test
    Room = Struct.new(:height, :width, :large, :computers, :conference_hall)

    # Literal transcription of the 2018 PdfController loops (optimal cable
    # and economic raceway), kept as the reference the refactor must match.
    def legacy_cable(room)
      cable = 0
      cable += 2 * room.height + room.width + room.large + 4 if room.conference_hall
      cont = 0
      cable += (0.5 + (room.height * 2) + 2)
      i = 0
      while i < room.large
        j = 0
        while j < room.width
          if j != 0 && i.even? && cont < room.computers
            cont += 1
            cable = if i == 0
                      (0.5 + (room.height * 2) + (j + 1) + 2) + cable
                    else
                      (0.5 + (room.height * 2) + ((i + 1) + (j + 1)) + 2) + cable
                    end
          end
          j += 1
        end
        i += 1
      end
      cable
    end

    def legacy_raceway(room)
      cont = 0
      canaleta = 1
      i = 0
      while i < room.large
        j = 0
        while j < room.width
          if j != 0 && i.even? && cont < room.computers
            canaleta = 1 + canaleta
            cont += 1
            canaleta = (i + 1) + canaleta unless i == 0
          end
          j += 1
        end
        i += 1
      end
      canaleta
    end

    def test_matches_the_legacy_algorithm_room_by_room
      random = Random.new(2018)
      200.times do
        room = Room.new(random.rand(2..5), random.rand(1..12), random.rand(1..12), random.rand(0..80), random.rand < 0.3)
        estimator = CablingEstimator.new([room])

        assert_in_delta legacy_cable(room), estimator.cable_meters, 1e-9, room.inspect
        assert_equal legacy_raceway(room), estimator.raceway_meters, room.inspect
      end
    end

    def test_totals_add_up_across_rooms
      rooms = [Room.new(3, 6, 8, 20, false), Room.new(4, 10, 10, 35, true)]

      assert_in_delta rooms.map { |room| legacy_cable(room) }.reduce(:+), CablingEstimator.new(rooms).cable_meters
      assert_equal rooms.map { |room| legacy_raceway(room) }.reduce(:+), CablingEstimator.new(rooms).raceway_meters
    end

    def test_hand_computed_room
      # 2 computers in row 0 (columns 1 and 2) of a 3 m high room:
      # uplink 8.5 + (8.5 + 2) + (8.5 + 3) = 30.5 m of cable, 1 + 1 + 1 = 3 m of raceway.
      estimator = CablingEstimator.new([Room.new(3, 4, 2, 2, false)])

      assert_in_delta 30.5, estimator.cable_meters
      assert_equal 3, estimator.raceway_meters
    end

    def test_computers_beyond_the_grid_capacity_are_ignored
      small = Room.new(3, 3, 1, 100, false)

      assert_equal 3, CablingEstimator.new([small]).raceway_meters, 'a 1x3 grid seats two workstations'
    end

    def test_empty_design
      assert_equal 0, CablingEstimator.new([]).cable_meters
      assert_equal 0, CablingEstimator.new([]).raceway_meters
    end
  end
end
