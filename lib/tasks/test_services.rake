namespace :test do
  desc 'Run the framework-free domain service tests in test/services'
  task :services do
    ruby '-Itest', '-e', 'Dir["test/services/**/*_test.rb"].sort.each { |file| require "./#{file}" }'
  end
end
