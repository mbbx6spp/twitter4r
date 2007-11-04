require('rake/contrib/rubyforgepublisher')

namespace :web do
  desc "Build the website, but do not publish it"
  task :build => [:clobber, :coverage, 'spec:html', :webgen, :failing_examples_with_html, :examples_specdoc, :rdoc, :rdoc_rails]

  desc "Upload Website to RubyForge"
  task :publish => [:verify_user, :website] do
    publisher = Rake::SshDirPublisher.new(
      "rspec-website@rubyforge.org",
      "/var/www/gforge-projects/#{PKG_NAME}",
      "../doc/output"
    )
    publisher.upload
  end
end
