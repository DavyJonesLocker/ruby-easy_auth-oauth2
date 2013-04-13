require 'oauth2'

module EasyAuth::Models::Identities::Oauth2::Base
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def authenticate(controller)
      if controller.params[:code].present? && controller.params[:error].blank?
        callback_url   = controller.oauth2_callback_url(:provider => provider)
        code           = controller.params[:code]
        token          = client.auth_code.get_token(code, token_options(callback_url), token_params)
        user_info      = get_user_info(token)
        identity       = self.find_or_initialize_by_uid retrieve_uid(user_info)
        identity.token = token.token

        if controller.current_account
          if identity.account
            if identity.account != controller.current_account
              controller.flash[:error] = 'Error!'
              return nil
            end
          else
            identity.account = controller.current_account
          end
        else
          unless identity.account
            identity.account = EasyAuth.account_model.create!(account_attributes(user_info))
          end
        end

        identity.save!
        identity
      end
    end

    def account_attributes(user_info)
      EasyAuth.account_model.define_attribute_methods unless EasyAuth.account_model.attribute_methods_generated?
      setters = EasyAuth.account_model.instance_methods.grep(/=$/) - [:id=]
      account_attributes_map.inject({}) do |hash, kv|
        if setters.include?("#{kv[0]}=".to_sym)
          hash[kv[0]] = user_info[kv[1]]
        end

        hash
      end
    end

    def account_attributes_map
      { :email => 'email' }
    end

    # Returns the account uid value from available attributes
    def retrieve_uid(user_info)
      raise NotImplementedError
    end

    def new_session(controller)
      controller.redirect_to authenticate_url(controller.oauth2_callback_url(:provider => provider))
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

    def get_user_info(token)
      ActiveSupport::JSON.decode(token.get(user_info_url).body)
    end

    def client
      @client ||= ::OAuth2::Client.new(client_id, secret, :site => site_url, :authorize_url => authorize_url, :token_url => token_url)
    end

    def authenticate_url(callback_url)
      client.auth_code.authorize_url(:redirect_uri => callback_url, :scope => oauth2_scope)
    end

    def user_info_url
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

    def client_id
      settings.client_id
    end

    def secret
      settings.secret
    end

    def settings
      EasyAuth.oauth2[provider]
    end

    def provider
      self.to_s.split('::').last.underscore.to_sym
    end
  end

  def get_access_token
    self.class.get_access_token self
  end
end
