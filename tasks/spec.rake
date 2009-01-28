gem 'rspec', '>=1.0.0'
require('spec')
require('spec/rake/spectask')
require('spec/rake/verify_rcov')
#require('rcov_report')

gem 'ZenTest'
require('autotest')
require('autotest/rspec')

meta = Twitter::Meta.new(File.join(File.dirname(__FILE__), '..'))

namespace :spec do
  desc "Run specs"
  Spec::Rake::SpecTask.new(:html) do |t|
    t.spec_files = meta.spec_files
    t.spec_opts = ['--format', 'html:doc/spec/index.html', '--color']
  #  t.out = 'doc/spec/index.html'
    t.rcov = true
    t.rcov_opts = ['--html', '--exclude', "#{ENV['HOME']}/.autotest,spec,/usr/lib/ruby"]
    t.rcov_dir = 'doc/rcov'
    t.fail_on_error = true
  end

  desc "Run specs and output to console"
  Spec::Rake::SpecTask.new(:console) do |t|
    t.spec_files = meta.spec_files
    t.spec_opts = ['--color']
  end
end

desc "Run specs with coverage verification"
RCov::VerifyTask.new(:coverage => ["spec:console", "spec:html"]) do |t|
  t.threshold = 100
  t.index_html = 'doc/rcov/index.html'
end
