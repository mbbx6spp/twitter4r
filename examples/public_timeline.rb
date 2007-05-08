require 'twitter'

client = Twitter::Client.new(:login => 'mylogin', :password => 'mypassword')
statuses = client.public_timeline
# statuses is an array of Twitter::Status objects
# you can query Status objects like so...
statuses.each do |stat|
  puts stat.user.screen_name, stat.text
  puts
end
