require 'spec_helper'

describe EasyAuth::OAuth2::Models::Account do
  describe 'o_auth_identities relationship' do
    before do
      class OtherIdentity < EasyAuth::Identity; end
      class OAuth2IdentityA < EasyAuth::Identities::OAuth2::Base; end
      class OAuth2IdentityB < EasyAuth::Identities::OAuth2::Base; end

      @user = create(:user)
      @other_identity = OtherIdentity.create(:account => @user)
      @o_auth2_identity_a = OAuth2IdentityA.create(:account => @user)
      @o_auth2_identity_b = OAuth2IdentityB.create(:account => @user)
    end
    after do
      Object.send(:remove_const, :OtherIdentity)
      Object.send(:remove_const, :OAuth2IdentityA)
      Object.send(:remove_const, :OAuth2IdentityB)
    end

    it 'only returns OAuth identities' do
      @user.o_auth2_identities.should_not include(@other_identity)
      @user.o_auth2_identities.should     include(@o_auth2_identity_a)
      @user.o_auth2_identities.should     include(@o_auth2_identity_b)
    end
  end
end
