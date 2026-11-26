require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  test 'reports require a signed in user' do
    get '/pdf/empresa', request_id: 1

    assert_redirected_to new_user_session_path
  end

  test 'a signed in user reaches the home page' do
    sign_in create_user

    get '/'

    assert_response :success
  end
end
