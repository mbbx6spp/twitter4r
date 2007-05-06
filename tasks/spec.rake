require('spec/rake/spectask')
require('spec/rake/verify_rcov')

def ignored_spec_files
  (Dir.glob('spec/**/*_spec.rb') << 'spec/spec_helper.rb').join(',')
end

desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = 'spec/**/*.rb'
  t.spec_opts = ['--color']
  t.rcov = true
  t.rcov_opts = ['--html', '--exclude', ignored_spec_files] # '--xrefs'
  t.rcov_dir = 'doc/rcov'
end

desc "Run specs with coverage verification"
RCov::VerifyTask.new(:coverage => :spec) do |t|
  t.threshold = 100
  t.index_html = 'doc/rcov/index.html'
end
