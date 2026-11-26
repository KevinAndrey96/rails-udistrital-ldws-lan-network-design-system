require 'test_helper'
require 'minitest/mock'

class DesignWizardTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    sign_in @user
  end

  test 'a new company design saves every filled slot and ignores browser ids' do
    assert_difference %w(Company.count Request.count Binnacle.count), 1 do
      post '/process', wizard_params('false', my_company_id: '7001', my_request_id: '7002', my_logical_id: '7003')
    end

    request = Request.last
    assert_redirected_to panel_index_path(request_id: request.id)
    assert_equal @user.id, request.company.user_id
    assert_equal 'Campus', request.ctype
    assert_equal 2, request.required_server_count
    refute Request.exists?(7002)

    towers = request.buildings.order(:id)
    assert_equal ['Torre A', 'Torre B'], towers.map(&:name)
    assert_equal [towers.first.id, towers.last.id], request.physical.order(:computers).map(&:building_id)

    logical = Logical.find_by!(request_id: request.id)
    assert_equal %w(ventas), logical.subnets.map(&:name)
  end

  test 'another design for an existing company keeps the design type' do
    company = create_design(user: @user).company

    assert_no_difference -> { Company.count } do
      post '/process', wizard_params('true', my_company_id: company.id.to_s, ctype: 'Enterprise')
    end

    assert_equal 'Enterprise', company.request.order(:id).last.ctype
  end

  test "a design cannot be added to another user's company" do
    company = create_design(user: create_user(email: 'other@ldws.local')).company

    assert_no_difference -> { Request.count } do
      assert_raises(ActiveRecord::RecordNotFound) { post '/process', wizard_params('true', my_company_id: company.id.to_s) }
    end
  end

  test 'editing replaces floors and subnets without touching the design identity' do
    design = create_design(user: @user, ctype: 'Enterprise', rooms: [{ computers: 5 }] * 3, subnets: { 'legacy' => 4 })
    logical = Logical.find_by!(request_id: design.id)

    post '/process', wizard_params('edit', my_request_id: design.id.to_s, my_logical_id: '9999', ctype: 'Campus')

    design.reload
    assert_equal 'Sede norte', design.title
    assert_equal 'Enterprise', design.ctype
    assert_equal [12, 20], design.physical.map(&:computers).sort
    assert_equal logical.id, Logical.find_by!(request_id: design.id).id
    assert_equal %w(ventas), logical.subnets.reload.map(&:name)
    assert_equal 'Edición', Binnacle.last.action
  end

  test "another user's design cannot be edited" do
    design = create_design(user: create_user(email: 'other@ldws.local'))

    assert_raises(ActiveRecord::RecordNotFound) { post '/process', wizard_params('edit', my_request_id: design.id.to_s) }
    assert_equal 'Red sede principal', design.reload.title
  end

  test 'a failure halfway leaves no partial design behind' do
    Subnet.stub(:create!, ->(*) { raise ActiveRecord::StatementInvalid, 'disk full' }) do
      assert_no_difference -> { Company.count + Request.count + Building.count + Physical.count + Logical.count } do
        assert_raises(ActiveRecord::StatementInvalid) { post '/process', wizard_params('false') }
      end
    end
  end

  test 'the wizard form renders for a new company, a new design and an edit' do
    design = create_design(user: @user, subnets: { 'ventas' => 10 })

    [{ new: 'true' }, { new: 'false', id: design.company_id }, { edit: 'true', id: design.id }].each do |query|
      get '/process/index', query

      assert_response :success, query.inspect
    end
    assert_includes response.body, 'Red sede principal'
  end

  test 'an unknown wizard mode is rejected' do
    post '/process', wizard_params('maybe')

    assert_response :bad_request
  end

  private

  def wizard_params(mode, overrides = {})
    {
      otra_solicitud: mode, ctype: 'Campus',
      name: 'Acme S.A.S.', nit: '900123456', cell: '3001234567', phone: '6011234567', email: 'it@acme.test',
      my_request_title: 'Sede norte', my_request_description: 'Nueva sede', my_request_objective: 'LAN',
      my_request_observation: '', my_request_web: 'true', my_request_dns: 'true', my_request_ftp: 'false',
      building_1: 'true', building_id_1: '5001', building_name_1: 'Torre A', building_distance_1: '0',
      building_2: 'true', building_id_2: '5002', building_name_2: 'Torre B', building_distance_2: '120',
      fisico_1: 'true', my_physical_height_1: '3', my_physical_width_1: '6', my_physical_large_1: '8',
      my_physical_computers_1: '12', my_physical_printers_1: '1', my_physical_conference_hall_1: 'false',
      fisico_2: 'true', my_physical_height_2: '',
      fisico_11: 'true', my_physical_height_11: '3', my_physical_width_11: '5', my_physical_large_11: '6',
      my_physical_computers_11: '20', my_physical_printers_11: '0', my_physical_conference_hall_11: 'true',
      my_logical_host1: '10', my_logical_host2: '20', my_logical_host3: '30', my_logical_host4: '0',
      my_logical_redundancy: 'true', my_logical_scalability: '15', my_logical_security: 'true',
      subnet_1: 'true', my_subnet_name_1: 'ventas', my_subnet_description_1: 'Ventas', my_subnet_computers_1: '10',
      subnet_2: 'false', my_subnet_name_2: 'ignored'
    }.merge(overrides)
  end
end
