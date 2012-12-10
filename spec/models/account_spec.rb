require 'spec_helper'

describe EasyAuth::Oauth2::Models::Account do
  describe 'oauth2_identities relationship' do
    before do
      class OtherIdentity   < Identity; end
      class Oauth2IdentityA < Identities::Oauth2::Base; end
      class Oauth2IdentityB < Identities::Oauth2::Base; end

      @user = create(:user)
      @other_identity    = OtherIdentity.create(:account => @user,   :username => @user.email)
      @oauth2_identity_a = Oauth2IdentityA.create(:account => @user, :username => @user.email)
      @oauth2_identity_b = Oauth2IdentityB.create(:account => @user, :username => @user.email)
    end

    after do
      Object.send(:remove_const, :OtherIdentity)
      Object.send(:remove_const, :Oauth2IdentityA)
      Object.send(:remove_const, :Oauth2IdentityB)
    end

    it 'only returns OAuth identities' do
      @user.oauth2_identities.should_not include(@other_identity)
      @user.oauth2_identities.should     include(@oauth2_identity_a)
      @user.oauth2_identities.should     include(@oauth2_identity_b)
    end
  end
end
