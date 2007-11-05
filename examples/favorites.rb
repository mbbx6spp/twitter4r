require('twitter')
require('twitter/console')

ids = [388403452, 388338112, 388334732, 388294752]
client = Twitter::Client.from_config('config/twitter.yml')

statuses = client.favorites

statuses.each do |status|
  client.favorite(:remove, status)
end

ids.each do |id|
  old_count = client.favorites.size
  client.favorite(:add, id)
  new_count = client.favorites.size
  text = (new_count == old_count + 1) ? "Successfully added status with id #{id}" : "Failed"
  puts text
end

