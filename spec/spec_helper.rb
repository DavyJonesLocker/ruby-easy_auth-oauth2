require 'bundler/setup'
require 'byebug'
require 'rspec'
require 'valid_attribute'
require 'factory_girl'
require 'rails'
require 'easy_auth-oauth2'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

Dir[File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb')].each { |f| require f }
Dir[File.join(ENGINE_RAILS_ROOT, 'spec/config/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
  config.include FactoryGirl::Syntax::Methods
end

I18n.enforce_available_locales = true
