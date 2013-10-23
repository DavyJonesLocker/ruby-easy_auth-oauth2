generate('easy_auth:setup')

file 'config/database.yml', :force => true do
<<-CONFIG
test:
  adapter: postgresql
  encoding: unicode
  database: easy_auth-oauth2_test
  pool: 5
  username: <%= ENV['DB_USERNAME'] || 'postgres' %>
  password:
  min_messages: warning
development:
  adapter: postgresql
  encoding: unicode
  database: easy_auth-oauth2_development
  pool: 5
  username: <%= ENV['DB_USERNAME'] || 'postgres' %>
  password:
  min_messages: warning
CONFIG
end

generate(:model, 'user email:string session_token:string -t false')

insert_into_file 'app/models/user.rb', :after => "class User < ActiveRecord::Base\n" do
  "  include EasyAuth::Models::Account\n"
end

route 'easy_auth_routes'
