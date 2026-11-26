require 'test_helper'

class AddressingReportTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    sign_in @user
  end

  test 'addressing report is rendered as a pdf without any external service' do
    request = create_design(user: @user, rooms: [{ computers: 60 }], subnets: { 'ventas' => 30 })

    get '/pdf/direccionamiento', request_id: request.id

    assert_response :success
    assert_equal 'application/pdf', response.content_type
    assert response.body.start_with?('%PDF')
    assert_equal %w(default ventas), request.logical.subnets.order(:name).pluck(:name)
  end

  test 'an exhausted address space is reported instead of crashing' do
    request = create_design(user: @user, rooms: [{ computers: 300 }])
    request.logical.update!(host1: 255, host2: 255, host3: 255)

    get '/pdf/direccionamiento', request_id: request.id

    assert_response :unprocessable_entity
    assert_match(/address space exhausted/, response.body)
  end
end
