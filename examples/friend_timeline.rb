require 'twitter'

client = Twitter::Client.new(:login => 'mylogin', :password => 'mypassword')
statuses = client.friend_timeline
# statuses is an array of Twitter::Status objects
# you can query Status objects like so...
statuses.each do |stat|
  puts stat.user.login, stat.message
  puts
end
