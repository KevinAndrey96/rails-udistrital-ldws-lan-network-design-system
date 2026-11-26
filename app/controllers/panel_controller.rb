class PanelController < ApplicationController
  before_action :authenticate_user!
  def index
    id = params[:request_id]
    @request=accessible_requests.find(id)
    @company=@request.company
  end
end
