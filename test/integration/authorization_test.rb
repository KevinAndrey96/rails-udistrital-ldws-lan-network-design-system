require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  ADMIN_ONLY_PATHS = %w(/manage_users /equipment /switches /the_switches /ports /cables /categories
                        /connectors /ethernets /binnacles /physicals /logicals /buildings /subnets /pruebas/index).freeze

  setup do
    @owner = create_user(email: 'owner@ldws.local')
    @design = create_design(user: @owner)
    @intruder = create_user(email: 'intruder@ldws.local')
  end

  test 'admin areas reject anonymous visitors' do
    ADMIN_ONLY_PATHS.each do |path|
      get path

      assert_redirected_to new_user_session_path, path
    end
  end

  test 'admin areas reject regular users' do
    sign_in @intruder

    ADMIN_ONLY_PATHS.each do |path|
      get path

      assert_redirected_to root_path, path
    end
  end

  test 'a regular user cannot promote themselves to admin' do
    sign_in @intruder

    patch "/manage_users/#{@intruder.id}", user: { role: User::ADMIN_ROLE }

    assert_redirected_to root_path
    refute @intruder.reload.admin?
  end

  test 'admins reach the admin areas' do
    sign_in create_user(email: 'admin@ldws.local', role: User::ADMIN_ROLE)

    get '/manage_users'

    assert_response :success
  end

  test "another user's design is not found" do
    ["/panel/index?request_id=#{@design.id}", "/pdf/empresa?request_id=#{@design.id}",
     "/report/index?request_id=#{@design.id}", "/requests/#{@design.id}", "/companies/#{@design.company_id}",
     "/process/index?edit=true&id=#{@design.id}"].each do |path|
      # A raised request never stores the session cookie, so sign in for each one.
      sign_in @intruder

      assert_raises(ActiveRecord::RecordNotFound, path) { get path }
    end
  end

  test 'company listings only show the owner companies' do
    sign_in @intruder

    get '/companies'

    assert_response :success
    refute_includes response.body, @design.company.name
  end

  test 'admins can open any design' do
    sign_in create_user(email: 'admin@ldws.local', role: User::ADMIN_ROLE)

    get '/panel/index', request_id: @design.id

    assert_response :success
  end
end
