$:.push File.expand_path('../lib', __FILE__)

require 'easy_auth/o_auth2/version'

Gem::Specification.new do |s|
  s.name        = 'easy_auth-o_auth2'
  s.version     = EasyAuth::OAuth2::VERSION
  s.authors     = ['Brian Cardarella', 'Dan McClain']
  s.email       = ['brian@dockyard.com', 'bcardarella@gmail.com', 'rubygems@danmcclain.net']
  s.homepage    = 'https://github.com/dockyard/easy_auth-o_auth2'
  s.summary     = 'EasyAuth-OAuth2'
  s.description = 'EasyAuth-OAuth2'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  s.add_dependency 'easy_auth', '~> 0.1.0'
  s.add_dependency 'oauth2',    '~> 0.8.0'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'valid_attribute'
  s.add_development_dependency 'factory_girl', '~> 2.6.0'
  s.add_development_dependency 'bourne'
end
