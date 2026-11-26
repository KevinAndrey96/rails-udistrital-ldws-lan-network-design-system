ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |file| require file }

class ActiveSupport::TestCase
  include NetworkDesignFactory
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include NetworkDesignFactory
end
