require('rubygems')
gem('twitter4r', '>=0.2.0')
module Twitter; end

# For better unicode support
$KCODE = 'u'
require 'jcode'

# External requires
require('net/https')
require('uri')
require('json')

# Ordering matters...pay attention here!
#require('twitter/ext/stdlib')
require('twitter/version')
require('twitter/meta')
require('twitter/core')
require('twitter/model')
require('twitter/config')
require('twitter/client')
require('twitter/console')

Twitter::Client.configure do |conf|
  # We can set Twitter4R to use :ssl or :http to connect to the Twitter API.
  # Defaults to :ssl
  conf.protocol = :ssl

  # We can set Twitter4R to use another host name (perhaps for internal
  # testing purposes).
  # Defaults to 'twitter.com'
  conf.host = 'twitter.com'

  # We can set Twitter4R to use another port (also for internal
  # testing purposes).
  # Defaults to 443
  conf.port = 443

  # We can set proxy information for Twitter4R
  # By default all following values are set to nil.
  #conf.proxy_host = 'myproxy.host'
  #conf.proxy_port = 8080
  #conf.proxy_user = 'myuser'
  #conf.proxy_pass = 'mypass'

  # We can also change the User-Agent and X-Twitter-Client* HTTP headers
  conf.user_agent = 'MyAppAgentName'
  conf.application_name = 'MyAppName'
  conf.application_version = 'v1.5.6'
  conf.application_url = 'http://myapp.url'
end

# Temporary Rails patch for Twitter4R v0.2.x (where x<=3)
class String
  def xmlize
    comps = self.split('::')
    cls = comps.pop
    "#{comps.join('-')}:#{cls}".downcase
  end
end

module Twitter::RailsPatch
  class << self
    def included(base)
      base.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
      def to_param
        self.id.to_s
      end
      
      def to_xml(options = {})
        elem = self.class.name.xmlize
        xml = ""
        xml << (options[:skip_instruct] ? "<#{elem}>" : "<?xml version=\"1.0\"><#{elem}>")
        self.class.attributes.each do |att|
          xml << (att.respond_to?(:to_xml) ? att.to_xml : "<#{att}>#{self.send(att).to_s}</#{att}>")
        end
        xml << "</#{elem}>"
        puts xml
        xml
      end
      
      def to_json(options = {})
        JSON.unparse(self.to_hash)
      end
    end
  end
end

class Twitter::User
  include Twitter::RailsPatch
end

class Twitter::Status
  include Twitter::RailsPatch
end

class Twitter::Message
  include Twitter::RailsPatch
end

class Hash
  def to_http_str
    result = ''
    return result if self.empty?
    self.each do |key, val|
      result << "#{key}=#{URI.encode(val.to_s)}&"
    end
    result.chop # remove the last '&' character, since it can be discarded
  end
end

class Time
  def to_s(format = :rfc822)
    self.to_formatted_s(format)
  end
end
