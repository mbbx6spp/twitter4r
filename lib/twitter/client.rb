# client.rb contains the classes, methods and extends <tt>Twitter4R</tt> 
# features to define client calls to the Twitter REST API.
# 
# See:
# * <tt>Twitter::Client</tt>

# Used to query or post to the Twitter REST API to simplify code.
class Twitter::Client
  include Twitter::ClassUtilMixin
end

require('twitter/client/base.rb')
require('twitter/client/timeline.rb')
require('twitter/client/status.rb')
require('twitter/client/friendship.rb')
require('twitter/client/messaging.rb')
require('twitter/client/user.rb')
require('twitter/client/auth.rb')
require('twitter/client/favorites.rb')

