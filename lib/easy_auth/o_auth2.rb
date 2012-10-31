require 'easy_auth'
require 'easy_auth/o_auth2/engine'
require 'easy_auth/o_auth2/version'

module EasyAuth

  module OAuth2
    extend ActiveSupport::Autoload
    autoload :Controllers
    autoload :Models
    autoload :Routes
  end

  module Models::Account
    include EasyAuth::OAuth2::Models::Account
  end

  module Controllers::Sessions
    include EasyAuth::OAuth2::Controllers::Sessions
  end

  def self.o_auth2_identity_model(controller)
    send("o_auth2_#{controller.params[:provider]}_identity_model", controller)
  end

  class << self
    attr_accessor :o_auth2
  end

  self.o_auth2 = {}

  def self.o_auth2_client(provider, client_id, secret, scope = '')
    o_auth2[provider] = OpenStruct.new :client_id => client_id, :secret => secret, :scope => scope || ''
  end
end

ActionDispatch::Routing::Mapper.send(:include, EasyAuth::OAuth2::Routes)
