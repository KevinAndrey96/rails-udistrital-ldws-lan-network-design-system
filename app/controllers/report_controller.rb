class ReportController < ApplicationController
  before_action :authenticate_user!
  def index
      
    if params[:id]
      @company=accessible_companies.find(params[:id])
      @request=Request.where(:company_id => @company.id).first
    elsif params[:request_id]
      @request=accessible_requests.find(params[:request_id])
      @company=@request.company
      @physical=Physical.where(:request_id => @request.id)
      @logical=Logical.where(:request_id => @request.id)
    end
      
  end
end