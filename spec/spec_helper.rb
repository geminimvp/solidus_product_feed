# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require File.expand_path('dummy/config/environment.rb', __dir__)

require 'rspec/rails'
require 'devise'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

require 'solidus_product_feed/factories'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::Api::TestingSupport::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.fail_fast = ENV['FAIL_FAST'] || false
end
