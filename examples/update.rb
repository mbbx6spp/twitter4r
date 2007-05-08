require 'twitter'

client = Twitter::Client.new(:login => 'mylogin', :password => 'mypassword')
begin
  client.update('Twitter4R is so cool')
rescue RESTError, re
  puts re
end
