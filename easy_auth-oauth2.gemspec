$:.push File.expand_path('../lib', __FILE__)

require 'easy_auth/oauth2/version'

Gem::Specification.new do |s|
  s.name        = 'easy_auth-oauth2'
  s.version     = EasyAuth::Oauth2::VERSION
  s.authors     = ['Brian Cardarella', 'Dan McClain']
  s.email       = ['brian@dockyard.com', 'bcardarella@gmail.com', 'rubygems@danmcclain.net']
  s.homepage    = 'https://github.com/dockyard/ruby-easy_auth-oauth2'
  s.summary     = 'EasyAuth-Oauth2'
  s.description = 'EasyAuth-Oauth2'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  s.add_dependency 'easy_auth', '~> 0.3.0'
  s.add_dependency 'easy_auth-oauth_core'
  s.add_dependency 'oauth2',    '~> 0.9.1'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'valid_attribute'
  s.add_development_dependency 'factory_girl', '~> 4.2.0'
  s.add_development_dependency 'mocha', '~> 0.10.5'
end
