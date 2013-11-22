require 'active_record'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
        :adapter => 'postgresql',
        :database => 'easy_auth_oauth2_test'
    )
    drop_users       = %{DROP TABLE IF EXISTS users;}
    drop_identities  = %{DROP TABLE IF EXISTS identities;}
    users_table      = %{CREATE TABLE users (id SERIAL PRIMARY KEY, email VARCHAR(255));}
    identities_table = %{CREATE TABLE identities (id SERIAL PRIMARY KEY, uid VARCHAR(255)[], token VARCHAR(255), account_type VARCHAR(255), account_id INTEGER, type VARCHAR(255));}
    ActiveRecord::Base.connection.execute(drop_users)
    ActiveRecord::Base.connection.execute(drop_identities)
    ActiveRecord::Base.connection.execute(users_table)
    ActiveRecord::Base.connection.execute(identities_table)

    class ::User < ActiveRecord::Base
      include EasyAuth::Models::Account
    end
  end
end
