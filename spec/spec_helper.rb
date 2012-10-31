require 'rubygems'
begin
  require 'debugger'
rescue LoadError
end
begin
  require 'ruby-debug'
rescue LoadError
end
require 'bundler/setup'

require 'rspec'
require 'valid_attribute'
require 'factory_girl'
require 'bourne'
require 'rails'
require 'easy_auth-o_auth2'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

Dir[File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb')].each { |f| require f }
Dir[File.join(ENGINE_RAILS_ROOT, 'spec/config/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Factory::Syntax::Methods
end
