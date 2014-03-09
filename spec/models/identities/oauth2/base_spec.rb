require 'spec_helper'

class BaseTestController < ActionController::Base
  def initialize(request = OpenStruct.new(parameters: {}))
    super()
    @_request = request
  end

  def current_account
    nil
  end

  def oauth2_callback_url(options = {})
    ''
  end
end

class SessionsController < BaseTestController
  include EasyAuth::Controllers::Sessions

  def user_url(user)
    "/users/#{user.id}"
  end

  def after_failed_sign_in
    render text: ''
  end
end

class UsersController < BaseTestController
  def create
    User.create(user_params)
    redirect_to '/'
  end

  private

  def user_params
    params.require(:user).permit!
  end
end

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
      let(:controller) { SessionsController.new }

      it 'returns nil when :code param is missing' do
        TestIdentity.authenticate(controller).should be_nil
      end

      it 'returns nil when :error is not blank' do
        controller.params[:code]  = '123'
        controller.params[:error] = '123'
        TestIdentity.authenticate(controller).should be_nil
      end
    end

    context 'success states' do
      let(:run_controller) { SessionsController.action(:create).call(Rack::MockRequest.env_for("?#{{code: '123', identity: 'oauth2', provider: 'test_identity'}.to_param}")) }
      let(:email) { FactoryGirl.generate(:email) }

      before do
        token = mock('Token')
        token.stubs(:token).returns('123')
        token.stubs(:get).returns(OpenStruct.new(:body => {email: email}.to_json ))
        TestIdentity.client.auth_code.stubs(:get_token).returns(token)
      end

      context 'identity does not exist' do
        context 'linking to an existing account' do
          before do
            @user = create(:user)
            SessionsController.any_instance.stubs(:current_account).returns(@user)
          end

          it 'returns an identity' do
            run_controller
            @user.identities.first.should be_instance_of(TestIdentity)
          end

          it 'creates a new identity' do
            expect {
              run_controller
            }.to change { TestIdentity.count }.by(1)
          end
        end

        context 'creating a new account' do
          it 'creates a new account' do
            expect {
              run_controller
            }.to change { User.count }.by(1)
          end

          it 'creates a new identity' do
            expect {
              run_controller
            }.to change { TestIdentity.count }.by(1)
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
            SessionsController.any_instance.stubs(:current_account).returns(@user)
          end

          it 'returns an identity' do
            run_controller
            @user.identities.first.should eq @test_identity
          end

          it 'does not create a new identity' do
            expect {
              identity
            }.to_not change { TestIdentity.count }
          end

          context 'identity account and current account mismatch' do
            before do
              @test_identity.update_attribute(:account, create(:user))
              run_controller
            end

            it 'does not overwrite the account' do
              @test_identity.account.should_not eq @user
            end

            it 'sets an error flash' do
              pending
            end
          end
        end
      end
    end
  end
end
