require 'rails'
require 'action_controller/railtie'

module TestApp
  class Application < Rails::Application
    config.root = File.dirname(__FILE__)
    config.active_support.deprecation = :log
    config.logger = Logger.new(STDOUT)
  end
end

TestApp::Application.initialize!
