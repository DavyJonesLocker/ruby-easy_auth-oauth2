require 'spec_helper'

describe 'Config' do
  before do
    EasyAuth.config do |c|
      c.oauth2_client :google, 'client_id', 'secret'
    end
  end

  it 'sets the value to the class instance variable' do
    EasyAuth.oauth2[:google].client_id.should eq 'client_id'
    EasyAuth.oauth2[:google].secret.should    eq 'secret'
  end
end
