# Plain Minitest setup for the framework-free domain services in
# app/services. These suites load no Rails code, so they run on any Ruby:
#
#   ruby -Itest -e 'Dir["test/services/**/*_test.rb"].each { |f| require "./#{f}" }'
require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path('../app/services', __dir__)
