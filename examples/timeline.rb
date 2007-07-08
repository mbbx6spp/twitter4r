# = Timeline API Examples
#  require('rubygems')
#  gem('twitter4r', '0.2.0')
#  require('twitter')
# 
# The following is only required if you want to use some configuration 
# helper methods like <tt>Twitte4R::Client.from_config</tt> for 
# sensitive/instance context.
#  require 'twitter/console'
#  config_file = File.join(File.dirname(__FILE__), '..', 'config', 'twitter.yml')
#  
# 
# To override client connection configuration please refer to 
# the {<tt>configure.rb</tt>}[file:configure_rb.html] example code.
#  twitter = Twitter::Client.from_config(config_file)
# 
# This returns the public timeline as an <tt>Array</tt>.
# 
# We pass a block in to do something with each status returned inline.
# However, we still get to keep the <tt>public_timeline</tt> array after 
# the method returns, for our application's safe keeping.
# 
# It is not necessary to pass in a block to this method, so don't worry if 
# you don't want to do that.  All calls to <tt>Twitter::Client#timeline_for</tt>
# can pass in a block that works the same way as explained here.
#  public_timeline = twitter.timeline_for(:public) do |status|
#    puts status.user.screen_name, status.text
#  end
# 
# This returns the timeline for all your friends as an <tt>Array</tt>.
# See public timeline example above for discussion about passing in block,
# which is possible to all calls to <tt>Twitter::Client#timeline_for</tt>.
#  all_friends_timeline = twitter.timeline_for(:friends)
# 
# This returns the timeline for a particular friend.
#  myfriend_timeline = twitter.timeline_for(:friend, :id => 'dictionary')
# 
# This returns the timeline for a particular user (who may or may not be a friend).
#  user_timeline = twitter.timeline_for(:user, :id => 'twitter4r')
# 
# This returns the authenticated user's timeline
# 
# We can also use the following code snippet, which is equivalent to the example below:
#  my_timeline = twitter.my(:timeline)
# See Status API examples in <tt>status.rb</tt> file.
#  my_timeline = twitter.timeline_for(:me)
# 
# Below we demonstrate how to use more interesting parameters to the 
# <tt>Twitter::Client#timeline_for</tt> method
# 
# Returns all public statuses since the status id returned by:
#  public_timeline.first.id
#  latest_timeline = twitter.timeline_for(:public, :since_id => public_timeline.first.id)
# 
# Returns all friend statuses in the last 24 hours:
#  yesterday = Time.now - 60*60*24
#  new_friends_timeline = twitter.timeline_for(:friends, :since => yesterday)
# 
# Returns last three statuses from user <tt>'twitter4r'</tt>:
#  latest_twitter4r_timeline = twitter.timeline_for(:user, :id => 'twitter4', :count => 3)
# 
# Returns timeline from user <tt>'dictionary'</tt> since yesterday at this time, 
# with block:
#  new_dictionary_timeline = twitter.timeline_for(:user, :id => 'dictionary', :since => yesterday) do |status|
#    puts status.text
#  end
