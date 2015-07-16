ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require "email_spec"
require_relative 'helpers'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# for CanCan
require 'cancan/matchers'

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.before :each do
    DatabaseCleaner.start
  end
  config.after :each do
    DatabaseCleaner.clean
  end

#  config.include(EmailSpec::Helpers)
#  config.include(EmailSpec::Matchers)
  config.include Helpers
  config.include Warden::Test::Helpers
  config.include Devise::TestHelpers, type: :controller
end

Warden.test_mode!
