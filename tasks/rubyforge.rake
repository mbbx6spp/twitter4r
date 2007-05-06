require('rake/contrib/rubyforgepublisher')

publisher = Rake::CompositePublisher.new
publisher.add(Rake::RubyForgePublisher.new('twitter4r', 'mbbx6spp'))
publisher.add(Rake::SshDirPublisher.new("mbbx6spp@rubyforge.org", 
                                        "/var/www/gforge-projects/twitter4r", 
                                        "doc").upload)


task :publish_doc do
  publish.upload
end

#task :verify_user do
#  raise "RUBYFORGE_USER environment variable not set!" unless ENV['RUBYFORGE_USER']
#end
