require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rails/dummy/tasks'
Bundler::GemHelper.install_tasks

ENV['ENGINE'] ||= 'easy_auth'
ENV['TEMPLATE'] ||= 'spec/template.rb'
RSpec::Core::RakeTask.new('default') do |t|
  Rake::Task['dummy:app'].invoke unless ENV['SKIP_DUMMY_APP']
  t.rspec_opts = "-I #{File.expand_path('../spec/', __FILE__)}"
  t.pattern = FileList[File.expand_path('../spec/**/*_spec.rb', __FILE__)]
end
