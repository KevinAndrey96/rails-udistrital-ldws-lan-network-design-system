# == Schema Information
#
# Table name: logicals
#
#  id          :integer          not null, primary key
#  request_id  :integer
#  host1       :integer
#  host2       :integer
#  host3       :integer
#  host4       :integer
#  redundancy  :boolean
#  scalability :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  security    :boolean
#
# Indexes
#
#  index_logicals_on_request_id  (request_id)
#

class Logical < ActiveRecord::Base
  DEFAULT_SUBNET_NAME = 'default'.freeze

  belongs_to :request
  has_many :subnets

  # Network the VLSM plan starts from: the first three octets entered in the
  # wizard, with the host octet zeroed.
  def base_network
    "#{host1}.#{host2}.#{host3}.0"
  end

  # Computers not assigned to a named subnet are grouped in a "default"
  # subnet so that every host receives an address.
  def ensure_default_subnet!(total_computers)
    unassigned = total_computers.to_i - subnets.sum(:computers)
    return if unassigned <= 0 || subnets.exists?(name: DEFAULT_SUBNET_NAME)

    subnets.create!(name: DEFAULT_SUBNET_NAME, description: 'Sub red Default', computers: unassigned)
  end

  # growth: true sizes every subnet for the projected scalability percentage.
  def addressing_plan(growth: false)
    demands = subnets.reload.map do |subnet|
      hosts = growth ? NetworkDesign::VlsmPlanner.projected_hosts(subnet.computers, scalability) : subnet.computers
      [subnet.name, hosts]
    end

    NetworkDesign::VlsmPlanner.new(base_network).plan(demands)
  end
end
