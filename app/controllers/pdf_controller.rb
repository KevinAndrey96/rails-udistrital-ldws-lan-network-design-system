# PDF deliverables of a network design request. Every action renders one
# report; "final" bundles the company summary, the addressing plan and the
# three quotations in a single document.
class PdfController < ApplicationController
  REPORT_NAME = 'Reporte'.freeze

  # Instance variables the report views read for each equipment type: the
  # availability flag, then the tier chosen by the economic, standard and
  # optimal quotations (power 1 to 3, 0 when out of stock).
  QUOTED_EQUIPMENT = {
    'Switch' => %w(Sw_status eco est opt),
    'Router' => %w(R_status eco_r est_r opt_r),
    'Rack' => %w(Ra_status eco_ra est_ra opt_ra),
    'Cable' => %w(Ca_status eco_ca est_ca opt_ca),
    'Canaleta' => %w(Can_status eco_can est_can opt_can),
    'Toma' => %w(T_status eco_t est_t opt_t),
    'Conector' => %w(Co_status eco_con est_co opt_co),
    'AP' => %w(Ap_status eco_ap est_ap opt_ap)
  }.freeze

  before_action :authenticate_user!
  before_action :load_design

  rescue_from NetworkDesign::VlsmPlanner::AddressingError do |error|
    render plain: "No fue posible calcular el direccionamiento VLSM: #{error.message}", status: :unprocessable_entity
  end

  def empresa
    assign_company_summary
    render_report 'empresa'
  end

  def direccionamiento
    assign_addressing
    render_report 'direccionamiento'
  end

  def switches
    assign_addressing
    render_report 'switches'
  end

  def routers
    assign_addressing
    render_report 'routers'
  end

  def topologia
    render_report 'topologia'
  end

  def cotizacion
    assign_quotation
    render_report 'cotizacion'
  end

  def red
    @physical = @physical.order(computers: :desc)
    assign_addressing
    render_report 'red'
  end

  def red2
    @physical = @physical.order(computers: :desc)
    assign_addressing
    render_report 'red2'
  end

  def final
    assign_company_summary
    assign_addressing
    assign_quotation
    render_report 'final'
  end

  private

  def load_design
    @request = accessible_requests.find(params[:request_id])
    @company = @request.company
    @physical = Physical.where(request_id: @request.id)
    @logical = Logical.find_by!(request_id: @request.id)
    @subnets = Subnet.where(logical_id: @logical.id)
  end

  def assign_company_summary
    @total_of_computers = @physical.sum(:computers)
    @servidores = @request.required_server_count
    assign_equipment_tiers
  end

  # @h: plan for today's computers, @g: plan including scalability growth.
  def assign_addressing
    @logical.ensure_default_subnet!(@physical.sum(:computers))
    @h = @logical.addressing_plan.to_report
    @g = @logical.addressing_plan(growth: true).to_report
  end

  def assign_quotation
    @Logical = @logical
    @total_of_computers = @physical.sum(:computers)
    assign_equipment_tiers

    cabling = NetworkDesign::CablingEstimator.new(@physical.to_a)
    @cable = cabling.cable_meters
    @canaleta = cabling.raceway_meters
  end

  def assign_equipment_tiers
    selector = NetworkDesign::EquipmentTierSelector.new(Equipment.distinct.pluck(:etype, :power))
    profiles = NetworkDesign::EquipmentTierSelector::PROFILES.keys

    QUOTED_EQUIPMENT.each do |etype, (status, *tier_variables)|
      instance_variable_set("@#{status}", selector.available?(etype) ? 1 : 0)
      profiles.zip(tier_variables) do |profile, variable|
        instance_variable_set("@#{variable}", selector.tier(etype, profile))
      end
    end
  end

  # ?debug renders the report as HTML, which is handy to inspect a layout.
  def render_report(template)
    render pdf: REPORT_NAME, template: "pdf/#{template}.html.erb", show_as_html: params.key?(:debug)
  end
end
