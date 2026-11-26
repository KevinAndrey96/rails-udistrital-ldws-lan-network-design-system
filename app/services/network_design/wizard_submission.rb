module NetworkDesign
  # Persists the design wizard form in a single transaction. The form posts
  # fixed slots: up to ten buildings, fifty floors (ten per building, in
  # building order) and ten subnets, each flagged "true" once filled in.
  # Record ids are assigned by the database; the ids the browser generates
  # are ignored.
  class WizardSubmission
    class UnknownModeError < StandardError; end

    NEW_COMPANY = 'false'.freeze
    NEW_REQUEST = 'true'.freeze
    EDIT = 'edit'.freeze
    FILLED = 'true'.freeze

    BUILDING_SLOTS = (1..10).freeze
    FLOOR_SLOTS = (1..50).freeze
    FLOORS_PER_BUILDING = 10
    SUBNET_SLOTS = (1..10).freeze

    COMPANY_FIELDS = %i(name nit cell phone email).freeze
    REQUEST_FIELDS = (%i(title description objective observation) + Request::SERVER_SERVICES).freeze
    FLOOR_FIELDS = %i(height width large computers printers conference_hall).freeze
    LOGICAL_FIELDS = %i(host1 host2 host3 host4 redundancy scalability security).freeze
    SUBNET_FIELDS = %i(name description computers).freeze

    CREATED_LOG = ['Crear', 'Se ha creado una solicitud completa (Con Empresa)'].freeze
    EDITED_LOG = ['Edición', 'Se ha editado una solicitud'].freeze

    # companies and requests are the scopes the user is allowed to write to.
    def initialize(params, user:, companies:, requests:)
      @params = params
      @user = user
      @companies = companies
      @requests = requests
    end

    def save!
      ActiveRecord::Base.transaction do
        request = persist_request
        create_floors(request, create_buildings(request))
        create_subnets(save_logical(request))
        log_activity(request)

        request
      end
    end

    private

    attr_reader :params

    def mode
      params[:otra_solicitud]
    end

    def persist_request
      case mode
      when NEW_COMPANY
        company = Company.create!(fields(COMPANY_FIELDS).merge(user_id: @user.id))
        create_request(company)
      when NEW_REQUEST
        create_request(@companies.find(params[:my_company_id]))
      when EDIT
        update_request(@requests.find(params[:my_request_id]))
      else
        raise UnknownModeError, "unknown wizard mode #{mode.inspect}"
      end
    end

    def create_request(company)
      Request.create!(fields(REQUEST_FIELDS, 'my_request').merge(company_id: company.id, ctype: params[:ctype]))
    end

    # The form shows the design type read only, so an edit keeps it.
    def update_request(request)
      request.update!(fields(REQUEST_FIELDS, 'my_request'))
      request.physical.destroy_all
      request.buildings.destroy_all

      request
    end

    def create_buildings(request)
      BUILDING_SLOTS.each_with_object({}) do |slot, buildings|
        next unless filled?("building_#{slot}")

        buildings[slot] = Building.create!(name: params["building_name_#{slot}"],
                                           distance: params["building_distance_#{slot}"], request_id: request.id)
      end
    end

    def create_floors(request, buildings)
      FLOOR_SLOTS.each do |slot|
        next unless filled?("fisico_#{slot}") && params["my_physical_height_#{slot}"].present?

        building = buildings[(slot - 1) / FLOORS_PER_BUILDING + 1]
        Physical.create!(fields(FLOOR_FIELDS, 'my_physical', slot).merge(request_id: request.id, building_id: building&.id))
      end
    end

    def save_logical(request)
      attributes = fields(LOGICAL_FIELDS, 'my_logical')
      return Logical.create!(attributes.merge(request_id: request.id)) unless mode == EDIT

      logical = Logical.find_by!(request_id: request.id)
      logical.update!(attributes)
      logical.subnets.destroy_all

      logical
    end

    def create_subnets(logical)
      SUBNET_SLOTS.each do |slot|
        next unless filled?("subnet_#{slot}")

        Subnet.create!(fields(SUBNET_FIELDS, 'my_subnet', slot).merge(logical_id: logical.id))
      end
    end

    def log_activity(request)
      action, description = mode == EDIT ? EDITED_LOG : CREATED_LOG
      Binnacle.create!(user_id: @user.id, action: action, description: description, company_id: request.company_id)
    end

    def filled?(flag)
      params[flag] == FILLED
    end

    # Maps fields to the wizard input names: "<prefix>_<field>_<slot>".
    def fields(names, prefix = nil, slot = nil)
      names.each_with_object({}) do |name, attributes|
        attributes[name] = params[[prefix, name, slot].compact.join('_')]
      end
    end
  end
end
