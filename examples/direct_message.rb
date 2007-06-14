require 'twitter'

client = Twitter::Client.new(:login => 'mylogin', :password => 'mypassword')
begin
  client.send_direct_message('friend_screen_name', 'Twitter4R is so cool, check it out at http://twitter4r.rubyforge.org')
rescue Twitter::RESTError => re
  puts re # perhaps try again also?  left as exercise.
end
