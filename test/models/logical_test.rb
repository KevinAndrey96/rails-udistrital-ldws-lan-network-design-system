require 'test_helper'

class LogicalTest < ActiveSupport::TestCase
  test 'base network keeps the first three octets and zeroes the host octet' do
    logical = Logical.new(host1: 10, host2: 20, host3: 30, host4: 77)

    assert_equal '10.20.30.0', logical.base_network
  end

  test 'unassigned computers are grouped in a single default subnet' do
    logical = create_design(rooms: [{ computers: 40 }, { computers: 20 }], subnets: { 'ventas' => 25 }).logical

    2.times { logical.ensure_default_subnet!(60) }

    default = logical.subnets.where(name: Logical::DEFAULT_SUBNET_NAME)
    assert_equal 1, default.count
    assert_equal 35, default.first.computers
  end

  test 'no default subnet when named subnets cover every computer' do
    logical = create_design(subnets: { 'ventas' => 40 }).logical

    logical.ensure_default_subnet!(40)

    assert_equal %w(ventas), logical.subnets.pluck(:name)
  end

  test 'addressing plan sizes subnets for the current and the projected demand' do
    logical = create_design(subnets: { 'ventas' => 50, 'it' => 10 }, scalability: 30).logical

    current = logical.addressing_plan.to_report
    projected = logical.addressing_plan(growth: true).to_report

    assert_equal '192.168.10.0', current['ventas']['subnet']
    assert_equal 26, current['ventas']['cidr']
    assert_equal 25, projected['ventas']['cidr'], '50 hosts plus 30% growth need a /25'
    assert_equal '192.168.10.128', projected['it']['subnet']
  end
end
