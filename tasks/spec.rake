gem 'rspec', '>=1.0.0'
require('spec')
require('spec/rake/spectask')
require('spec/rake/verify_rcov')

gem 'ZenTest'
require('autotest')
require('autotest/rspec')

desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = 'spec/**/*.rb'
  t.spec_opts = ['--color', '--format', 'html']
  t.out = 'doc/spec/index.html'
  t.rcov = true
  t.rcov_opts = ['--html', '--exclude', "#{ENV['HOME']}/.autotest,spec/"] #, '--xrefs']
  t.rcov_dir = 'doc/rcov'
  t.fail_on_error = true
end

desc "Run specs with coverage verification"
RCov::VerifyTask.new(:coverage => :spec) do |t|
  t.threshold = 100
  t.index_html = 'doc/rcov/index.html'
end
