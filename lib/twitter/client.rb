# client.rb contains the classes, methods and extends <tt>Twitter4R</tt> 
# features to define client calls to the Twitter REST API.
# 
# See:
# * <tt>Twitter::Client</tt>

# Used to query or post to the Twitter REST API to simplify code.
class Twitter::Client
  include Twitter::ClassUtilMixin
end

require('twitter/client/base')
require('twitter/client/timeline')
require('twitter/client/status')
require('twitter/client/friendship')
require('twitter/client/messaging')
require('twitter/client/user')
require('twitter/client/auth')
require('twitter/client/favorites')
require('twitter/client/blocks')
require('twitter/client/account')
require('twitter/client/graph')
require('twitter/client/profile')
require('twitter/client/search')
