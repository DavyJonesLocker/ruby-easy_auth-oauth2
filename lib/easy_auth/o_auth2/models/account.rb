module EasyAuth::OAuth2::Models::Account
  extend ActiveSupport::Concern

  included do
    has_many :o_auth2_identities, :class_name => 'EasyAuth::Identities::OAuth2::Base', :foreign_key => :account_id
  end
end
