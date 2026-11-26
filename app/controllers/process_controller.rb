# Design wizard: new=true starts a design for a new company, new=false adds
# a design to company :id and edit=true reopens design :id.
class ProcessController < ApplicationController
  # The edit form lists the floors of up to five buildings.
  EDITABLE_BUILDINGS = 5

  before_action :authenticate_user!

  rescue_from NetworkDesign::WizardSubmission::UnknownModeError do
    head :bad_request
  end

  def index
    if params[:new] == 'false'
      @id = params[:id]
      @company = accessible_companies.find(@id)
    elsif params[:edit] == 'true'
      load_design_for_edit(params[:id])
    end
  end

  def create
    request = NetworkDesign::WizardSubmission.new(params, user: current_user, companies: accessible_companies,
                                                          requests: accessible_requests).save!

    redirect_to panel_index_path(request_id: request.id)
  end

  private

  def load_design_for_edit(id)
    @request = accessible_requests.find(id)
    @company = @request.company
    @logical = Logical.find_by!(request_id: @request.id)
    @subnets = Subnet.where(logical_id: @logical.id)
    @buildings = Building.where(request_id: @request.id).order('id desc')
    @cont_building = @buildings.count

    buildings = Building.where(request_id: @request.id).order(:id).first(EDITABLE_BUILDINGS)
    EDITABLE_BUILDINGS.times do |index|
      building = buildings[index]
      floors = building ? Physical.where(request_id: @request.id, building_id: building.id) : Physical.none
      instance_variable_set("@physicals#{index + 1}", floors)
    end
  end
end
