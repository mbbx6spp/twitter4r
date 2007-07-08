# = Messaging API Examples
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
# To override client connection configuration please refer to 
# the {<tt>configure.rb</tt>}[file:configure_rb.html] example code.
#  twitter = Twitter::Client.from_config(config_file)
# 
# To retrieve a list of direct messages received by the authenticated user
# you may do the following:
#  messages = twitter.messages(:received)
# 
# To retrieve a list of direct messages sent by the authenticated user
# you may do the following:
#  messages = twitter.messages(:sent)
# 
# To send a direct message to another user, you can do the following:
#  text = 'Do you want to meet me at our favorite coffeeshop at 3pm?'
#  message = twitter.message(:post, text, 'myfriend')
# As with most methods that accept the user's screen name you can also use in 
# it's place either the unique integer user ID or the <tt>Twitter::User</tt>
# object representation of the desired recipient user.  For example,
#  friend = Twitter::User.find('myfriend', twitter)
#  message = twitter.message(:post, text, friend)
# OR
#  message = twitter.message(:post, text, friend.id)
# 
# To delete a direct message you can use the following code:
#  twitter.message(:delete, message)
# You may also pass in the unique integer message ID instead like:
#  twitter.message(:delete, message.id)
