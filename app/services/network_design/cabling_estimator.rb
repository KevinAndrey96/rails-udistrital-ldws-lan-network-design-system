module NetworkDesign
  # Structured cabling estimate (horizontal UTP cable and raceway) for the
  # rooms of a design.
  #
  # A room is modelled as a grid of `large` rows by `width` columns, in
  # metres. Workstations sit on the even rows, leaving column 0 as the
  # aisle, until every computer has a place. Each workstation is wired to
  # the room's rack: a vertical run of twice the ceiling height, the
  # distance across the grid and fixed slack at both ends.
  #
  # rooms: objects responding to height, width, large, computers and
  # conference_hall (ActiveRecord Physical rows or plain structs).
  class CablingEstimator
    PATCH_SLACK = 0.5
    RACK_SLACK = 2

    def initialize(rooms)
      @rooms = rooms
    end

    # Metres of UTP cable for every room, including one uplink run per room
    # and the extra run to the conference hall when the room has one.
    def cable_meters
      @rooms.map { |room| room_cable(room) }.reduce(0, :+)
    end

    # Metres of raceway: one metre at the rack per room, one per
    # workstation, and the row offset for workstations beyond the first row.
    def raceway_meters
      @rooms.map { |room| room_raceway(room) }.reduce(0, :+)
    end

    private

    def room_cable(room)
      height = room.height.to_i
      total = vertical_run(height)
      total += 2 * height + room.width.to_i + room.large.to_i + 4 if conference_hall?(room)
      each_workstation(room) { |row, column| total += vertical_run(height) + horizontal_run(row, column) }

      total
    end

    def room_raceway(room)
      total = 1
      each_workstation(room) { |row, _column| total += row.zero? ? 1 : row + 2 }

      total
    end

    def vertical_run(height)
      PATCH_SLACK + height * 2 + RACK_SLACK
    end

    def horizontal_run(row, column)
      row.zero? ? column + 1 : row + column + 2
    end

    def each_workstation(room)
      remaining = room.computers.to_i
      (0...room.large.to_i).step(2) do |row|
        (1...room.width.to_i).each do |column|
          return if remaining <= 0

          remaining -= 1
          yield row, column
        end
      end
    end

    def conference_hall?(room)
      room.respond_to?(:conference_hall?) ? room.conference_hall? : room.conference_hall
    end
  end
end
