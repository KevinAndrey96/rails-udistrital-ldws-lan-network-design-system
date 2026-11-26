require 'test_helper'

class PdfReportsTest < ActionDispatch::IntegrationTest
  REPORTS = %w(empresa direccionamiento switches routers topologia cotizacion red red2 final).freeze

  setup do
    ENV['LDWS_ADMIN_PASSWORD'] = 'seed-password'
    silence_stream(STDOUT) { load Rails.root.join('db', 'seeds.rb') }
    @user = create_user
    sign_in @user
  end

  [['Enterprise', false], ['Campus', true]].each do |ctype, redundancy|
    test "every report renders a pdf for a #{ctype} design (redundancy #{redundancy})" do
      request = create_design(user: @user, ctype: ctype, redundancy: redundancy,
                              rooms: [{ computers: 30 }, { computers: 18, conference_hall: true }],
                              subnets: { 'ventas' => 20, 'it' => 8 }, services: { web: true, dns: true })

      REPORTS.each do |report|
        get "/pdf/#{report}", request_id: request.id

        assert_response :success, report
        assert response.body.start_with?('%PDF'), "#{report} is not a pdf"
      end
    end
  end

  test 'reports use the requested design, not the first request of the company' do
    first = create_design(user: @user)
    second = Request.create!(title: 'Sede norte', company_id: first.company_id, ctype: 'Enterprise')
    Physical.create!(request_id: second.id, height: 3, width: 4, large: 4, computers: 12, conference_hall: false)
    Logical.create!(request_id: second.id, host1: 10, host2: 20, host3: 30, host4: 0, scalability: 0)

    get '/pdf/direccionamiento', request_id: second.id, debug: 1

    assert_response :success
    assert_includes response.body, 'Host: 10.20.30.0'
    assert_includes response.body, '10.20.30.1 - 10.20.30.14'
  end

  test 'quotation prices cabling for every room of the design' do
    request = create_design(user: @user, rooms: [{ computers: 10 }, { computers: 10 }])
    rooms = request.physical.to_a
    expected_raceway = NetworkDesign::CablingEstimator.new(rooms).raceway_meters

    get '/pdf/cotizacion', request_id: request.id, debug: 1

    assert_response :success
    assert_includes response.body, "#{expected_raceway} m"
    assert expected_raceway > NetworkDesign::CablingEstimator.new(rooms.last(1)).raceway_meters
  end
end
