#!/usr/bin/env ruby

require('twitter')
require('twitter/console')

version = Twitter::Version.to_version
config_file = File.join(File.dirname(__FILE__), '..', 'config', 'twitter.yml')
twitter = Twitter::Client.from_config(config_file)

def expect(n, m, message = 'A potential error')
	puts "WARNING: #{message}:\n\t => #{m} instead of #{n}" unless n.eql?(m)
end

timeline = twitter.timeline_for(:public)
count = timeline.size
expect 20, count, "Retrieved the last #{count} statuses from the public timeline"

sleep(5)
timeline = twitter.timeline_for(:friends)
count = timeline.size
expect 20, count, "Retrieved the last #{count} statuses from all my friends' timeline"

sleep(5)
timeline = twitter.timeline_for(:user, 
	:id => 'mbbx6spp', 
	:count => 5)
count = timeline.size
expect 5, count, "Retrieved the last #{count} statuses from one friend"

sleep(5)
screen_name = 'mbbx6spp'
user = twitter.user(screen_name)
expect screen_name, user.screen_name, 'Retrieved a different user'

sleep(5)
friends = twitter.user(screen_name, :friends)
expect Array, friends.class, 
	'Did not retrieve an Array of users for #user(..., :friends)'

sleep(5)
followers = twitter.my(:info).followers
expect Array, followers.class, 
	'Did not retrieve an Array of users for #my(:followers)'

sleep(5)
posted_status = twitter.status(:post, "Testing Twitter4R v#{version} - http://twitter4r.rubyforge.org")
timeline = twitter.timeline_for(:me, :count => 1)
expect Twitter::Status, posted_status.class, 'Did not return newly posted status'
expect 1, timeline.size, 'Did not retrieve only last status'
expect Array, timeline.class, 'Did not retrieve an Array'
expect timeline[0], posted_status, 'Did not successfully post new status'

sleep(5)
status = twitter.status(:get, posted_status.id)
expect posted_status, status, 'Did not get proper status'

sleep(5)
deleted_status = twitter.status(:delete, posted_status.id)
expect posted_status, deleted_status, 'Did not delete same status'

sleep(5)
text = 'This is a test direct message for sanity test script purposes'
message = twitter.message(:post, text, user)
expect text, message.text, 
	'Did not post expected text'
expect user.screen_name, message.recipient.screen_name, 
	'Did not post to expected recipient'

