require 'twitter'

client = Twitter::Client.new(:login => 'mylogin', :password => 'mypassword')
begin
  client.update_status('Twitter4R is so cool')
rescue RESTError, re
  puts re
end
