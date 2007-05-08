require 'twitter'

client = Twitter::Client.new(:login => 'mylogin', :password => 'mypassword')
statuses = client.follower_statuses
# statuses is an array of Twitter::Status objects
# you can query Status objects like so...
statuses.each do |stat|
  puts stat.user.screen_name, stat.text
  puts
end
