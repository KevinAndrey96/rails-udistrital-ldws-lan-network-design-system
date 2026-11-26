module PdfHelper
  FLOOR_PLAN_ICONS = %i(rack switch floor jack conference workstation).freeze

  def topology_diagram(request, logical)
    layout = request.ctype == 'Campus' ? 'campus' : 'enterprise'
    resilience = logical.redundancy? ? 'redundant' : 'non_redundant'

    wicked_pdf_image_tag "topology/#{layout}_#{resilience}.svg", alt: "Topología #{request.ctype}"
  end

  def floor_plan_icon(name)
    raise ArgumentError, "unknown floor plan icon #{name.inspect}" unless FLOOR_PLAN_ICONS.include?(name)

    wicked_pdf_image_tag "floor_plan/#{name}.svg", class: 'img-responsive', height: 30
  end
end
