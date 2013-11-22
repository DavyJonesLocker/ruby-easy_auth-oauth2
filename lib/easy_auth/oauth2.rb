require 'easy_auth'
require 'easy_auth/oauth2/engine'
require 'easy_auth/oauth2/version'

module EasyAuth

  module Oauth2
    extend ActiveSupport::Autoload
    autoload :Controllers
    autoload :Models
    autoload :Routes
  end

  module Models
    module Account
      include EasyAuth::Oauth2::Models::Account
    end

    module Identities
      autoload :Oauth2
    end
  end

  module Controllers::Sessions
    include EasyAuth::Oauth2::Controllers::Sessions
  end

  def self.oauth2_identity_model(params)
    method_name = "oauth2_#{params[:provider]}_identity_model"
    camelcased_provider_name = params[:provider].to_s.camelcase
    if respond_to?(method_name)
      send(method_name, params)
    else
      const_get("::Identities::Oauth2::#{camelcased_provider_name}")
    end
  rescue NameError
    camelcased_provider_name.constantize
  end

  class << self
    attr_accessor :oauth2
  end

  self.oauth2 = {}

  def self.oauth2_client(provider, client_id, secret)
    oauth2[provider] = OpenStruct.new :client_id => client_id, :secret => secret
  end
end

ActionDispatch::Routing::Mapper.send(:include, EasyAuth::Oauth2::Routes)
