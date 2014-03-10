require 'easy_auth-oauth_core'
require 'oauth2'

module EasyAuth::Models::Identities::Oauth2::Base
  extend ActiveSupport::Concern
  include EasyAuth::Models::Identities::OauthCore

  module ClassMethods
    def authenticate(controller)
      super(controller) do
        callback_url    = controller.oauth2_callback_url(:provider => provider)
        code            = controller.params[:code]
        token           = client.auth_code.get_token(code, token_options(callback_url), token_params)
        user_attributes = get_user_attributes(token)
        identity        = self.find_or_initialize_by(:uid => retrieve_uid(user_attributes))
        identity.token  = token.token

        [identity, user_attributes]
      end
    end

    def new_session(controller)
      controller.redirect_to authenticate_url(controller.oauth2_callback_url(:provider => provider))
    end

    def can_authenticate?(controller)
      controller.params[:code].present? && controller.params[:error].blank?
    end

    def get_access_token(identity)
      ::OAuth2::AccessToken.new client, identity.token
    end

    def oauth2_scope
      ''
    end

    def token_options(callback_url)
      { :redirect_uri => callback_url }
    end

    # Needed by some OAuth2 providers the use custom query parameters
    def token_params
      {}
    end

    def get_user_attributes(token)
      ActiveSupport::JSON.decode(token.get(user_attributes_url).body)
    end

    def client
      @client ||= ::OAuth2::Client.new(client_id, secret, :site => site_url, :authorize_url => authorize_url, :token_url => token_url)
    end

    def authenticate_url(callback_url)
      client.auth_code.authorize_url(:redirect_uri => callback_url, :scope => oauth2_scope)
    end

    def user_attributes_url
      raise NotImplementedError
    end

    def authorize_url
      raise NotImplementedError
    end

    def token_url
      raise NotImplementedError
    end

    def site_url
      raise NotImplementedError
    end
  end
end
