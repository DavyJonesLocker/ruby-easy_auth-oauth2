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

  module Models
    module Account
      include EasyAuth::OAuth2::Models::Account
    end

    module Identities
      autoload :OAuth2
    end
  end

  module Controllers::Sessions
    include EasyAuth::OAuth2::Controllers::Sessions
  end

  def self.o_auth2_identity_model(params)
    method_name = "o_auth2_#{params[:provider]}_identity_model"
    camelcased_provider_name = params[:provider].to_s.camelcase
    if respond_to?(method_name)
      send(method_name, params)
    elsif eval("defined?(Identities::OAuth2::#{camelcased_provider_name})")
      eval("Identities::OAuth2::#{camelcased_provider_name}")
    else
      camelcased_provider_name.constantize
    end
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
