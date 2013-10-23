ENV['RAILS_ENV'] ||= 'test'
require 'rspec'
require 'valid_attribute'
require 'factory_girl'
require 'rails'
require 'easy_auth-oauth2'
require File.expand_path('../dummy/config/environment', __FILE__)

Dir[Rails.root.join('../support/**/*.rb')].each {|f| require f}
Dir[Rails.root.join('../config/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
