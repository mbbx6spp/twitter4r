require('rake/contrib/rubyforgepublisher')

def rf_publisher
  rf_user = ENV['RUBYFORGE_USER']
  publisher = Rake::CompositePublisher.new
#  publisher.add(Rake::RubyForgePublisher.new('twitter4r', rf_user))
  publisher.add(Rake::SshDirPublisher.new("#{rf_user}@rubyforge.org", 
                                          "/var/www/gforge-projects/twitter4r/", 
                                          "doc"))
  publisher.add(Rake::SshDirPublisher.new("#{rf_user}@rubyforge.org",
                                          "/var/www/gforge-projects/twitter4r/",
                                          "../web"))


  publisher
end

namespace :publish do
  task :web do
    rf_publisher.upload
  end
end

