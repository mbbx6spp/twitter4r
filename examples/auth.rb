require('twitter')
require('twitter/console')

client = Twitter::Client.new
puts client.authenticate?("osxisforlightweights", "l30p@rd_s^cks!")

