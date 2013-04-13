require 'spec_helper'

describe EasyAuth::Models::Identities::Oauth2::Base do
  before(:all) do
    class TestIdentity < Identity
      include(EasyAuth::Models::Identities::Oauth2::Base)

      def self.user_info_url
        '/user'
      end

      def self.retrieve_uid(user_info)
        user_info['email']
      end
    end
  end

  before { TestIdentity.stubs(:client).returns(client) }

  after(:all) do
    Object.send(:remove_const, :TestIdentity)
  end

  let(:client)   { OAuth2::Client.new('client_id', 'secret', :site => 'http://example.com', :authorize_url => '/auth', :token_url => '/token' ) }
  let(:identity) { TestIdentity.new(:token => 'token') }

  context 'access tokens' do
    describe '.get_access_token' do
      it 'returns an OAuth Access Token' do
        access_token = TestIdentity.get_access_token identity
        access_token.class.should eq OAuth2::AccessToken
      end

      it "sets the token's client to the class's client" do
        access_token = TestIdentity.get_access_token identity
        access_token.client.should eq client
      end

      it "sets the token's token to the token passed in" do
        access_token = TestIdentity.get_access_token identity
        access_token.token.should eq 'token'
      end
    end

    describe '#get_access_token' do
      it 'returns an OAuth Access Token' do
        access_token = identity.get_access_token
        access_token.class.should eq OAuth2::AccessToken
      end

      it "sets the token's client to the class\'s client" do
        access_token = identity.get_access_token
        access_token.client.should eq client
      end

      it "sets the token's token to the token passed in" do
        access_token = identity.get_access_token
        access_token.token.should eq 'token'
      end

    end
  end

  describe '#authenticate' do
    context 'failure states' do
      let(:controller) { OpenStruct.new(:params => {}) }
      it 'returns nil when :code param is missing' do
        TestIdentity.authenticate(controller).should be_nil
      end

      it 'returns nil when :error is not blank' do
        controller.params[:code]  = '123'
        controller.params[:error] = '123'
        TestIdentity.authenticate(controller).should be_nil
      end

      context 'with invalid account' do
        let(:controller) { OpenStruct.new(:params => { :code => '123' }) }
        let(:identity) { TestIdentity.authenticate(controller) }
        let(:email) { FactoryGirl.generate(:email) }

        before do
          controller.stubs(:oauth2_callback_url).returns('')
          controller.stubs(:curent_account).returns(nil)
          token = mock('Token')
          token.stubs(:token).returns('123')
          token.stubs(:get).returns(OpenStruct.new(:body => {email: email}.to_json ))
          TestIdentity.client.auth_code.stubs(:get_token).returns(token)
          User.any_instance.stubs(:perform_validations).returns(false)
        end

        it 'raises ActiveRecord::RecordInvalid' do
          expect {
            identity
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'success states' do
      let(:controller) { OpenStruct.new(:params => { :code => '123' }, :flash => {}) }
      let(:identity) { TestIdentity.authenticate(controller) }
      let(:email) { FactoryGirl.generate(:email) }

      before do
        controller.stubs(:oauth2_callback_url).returns('')
        token = mock('Token')
        token.stubs(:token).returns('123')
        token.stubs(:get).returns(OpenStruct.new(:body => {email: email}.to_json ))
        TestIdentity.client.auth_code.stubs(:get_token).returns(token)
      end

      context 'identity does not exist' do
        context 'linking to an existing account' do
          before do
            @user = create(:user)
            controller.stubs(:current_account).returns(@user)
          end

          it 'returns an identity' do
            identity.should be_instance_of(TestIdentity)
          end

          it 'links to the account' do
            identity.account.should eq @user
          end
        end

        context 'creating a new account' do
          before do
            controller.stubs(:curent_account).returns(nil)
          end

          it 'returns an identity' do
            identity.should be_instance_of(TestIdentity)
          end

          it 'creates a new account' do
            expect {
              identity
            }.to change { User.count }.by(1)
          end

          it 'associated the new account with the identity' do
            identity.account.should_not be_nil
          end
        end
      end

      context 'identity already exists' do
        let(:email) { FactoryGirl.generate(:email) }

        before do
          @test_identity = TestIdentity.create(:uid => email, :token => '123')
        end

        context 'linking to an existing account' do
          before do
            @user = create(:user, :email => email)
            controller.stubs(:current_account).returns(@user)
          end

          it 'returns an identity' do
            identity.should be_instance_of(TestIdentity)
          end

          it 'links to the account' do
            identity.account.should eq @user
          end

          it 'does not create a new identity' do
            expect {
              identity
            }.to_not change { TestIdentity.count }
          end

          context 'identity account and current account mismatch' do
            before do
              @test_identity.update_attribute(:account, create(:user))
            end

            it 'returns nil' do
              identity.should be_nil
            end

            it 'sets the flash error' do
              identity
              controller.flash[:error].should_not be_nil
            end
          end
        end

        context 'creating a new account' do
          let(:identity) { TestIdentity.authenticate(controller) }
          before do
            controller.stubs(:curent_account).returns(nil)
          end

          it 'returns an identity' do
            identity.should be_instance_of(TestIdentity)
          end

          it 'creates a new account' do
            expect {
              identity
            }.to change { User.count }.by(1)
          end

          it 'does not create a new identity' do
            expect {
              identity
            }.to_not change { TestIdentity.count }
          end
        end
      end
    end
  end
end
