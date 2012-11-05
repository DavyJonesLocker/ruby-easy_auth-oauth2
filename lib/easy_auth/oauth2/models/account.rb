module EasyAuth::Oauth2::Models::Account
  extend ActiveSupport::Concern

  included do
    has_many :oauth2_identities, :class_name => 'Identities::Oauth2::Base', :foreign_key => :account_id
  end
end
