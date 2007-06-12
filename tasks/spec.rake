require('spec/rake/spectask')
require('spec/rake/verify_rcov')

desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = 'spec/**/*.rb'
  t.spec_opts = ['--color', '--format', 'html']
  t.out = 'doc/rspec/index.html'
  t.rcov = true
  t.rcov_opts = ['--html', '--exclude', "#{ENV['HOME']}/.autotest,spec/spec_helper.rb"] #, '--xrefs']
  t.rcov_dir = 'doc/rcov'
end

desc "Run specs with coverage verification"
RCov::VerifyTask.new(:coverage => :spec) do |t|
  t.threshold = 100
  t.index_html = 'doc/rcov/index.html'
end
