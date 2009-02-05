# config.rb contains classes, methods and extends existing Twitter4R classes 
# to provide easy configuration facilities.

module Twitter
  # Represents global configuration for Twitter::Client.
  # Can override the following configuration options:
  # * <tt>protocol</tt> - <tt>:http</tt>, <tt>:https</tt> or <tt>:ssl</tt> supported.  <tt>:ssl</tt> is an alias for <tt>:https</tt>.  Defaults to <tt>:ssl</tt>
  # * <tt>host</tt> - hostname to connect to for the Twitter service.  Defaults to <tt>'twitter.com'</tt>.
  # * <tt>port</tt> - port to connect to for the Twitter service.  Defaults to <tt>443</tt>.
  # * <tt>proxy_host</tt> - proxy host to use.  Defaults to nil.
  # * <tt>proxy_port</tt> - proxy host to use.  Defaults to nil.
  # * <tt>proxy_user</tt> - proxy username to use.  Defaults to nil.
  # * <tt>proxy_pass</tt> - proxy password to use.  Defaults to nil.
  # * <tt>user_agent</tt> - user agent string to use for each request of the HTTP header.
  # * <tt>application_name</tt> - name of your client application.  Defaults to 'Twitter4R'
  # * <tt>application_version</tt> - version of your client application.  Defaults to current <tt>Twitter::Version.to_version</tt>.
  # * <tt>application_url</tt> - URL of your client application.  Defaults to http://twitter4r.rubyforge.org.
  # * <tt>source</tt> - the source id given to you by Twitter to identify your application in their web interface.  Note: you must contact Twitter.com developer directly so they can configure their servers appropriately.
  class Config
    include ClassUtilMixin
    @@ATTRIBUTES = [
      :protocol, 
      :host, 
      :port, 
      :search_protocol,
      :search_host,
      :search_port,
      :proxy_host, 
      :proxy_port, 
      :proxy_user, 
      :proxy_pass, 
      :user_agent,
      :application_name,
      :application_version,
      :application_url,
      :source,
    ]
    attr_accessor *@@ATTRIBUTES
    
    # Override of Object#eql? to ensure RSpec specifications run 
    # correctly. Also done to follow Ruby best practices.
    def eql?(other)
      return true if self == other
      @@ATTRIBUTES.each do |att|
        return false unless self.send(att).eql?(other.send(att))
      end
      true
    end
  end

  class Client
    @@defaults = { :host => 'twitter.com', 
                   :port => 443, 
                   :protocol => :ssl,
                   :search_host => 'search.twitter.com',
                   :search_port => 80,
                   :search_protocol => :http,
                   :proxy_host => nil,
                   :proxy_port => nil,
                   :user_agent => "default",
                   :application_name => 'Twitter4R',
                   :application_version => Twitter::Version.to_version,
                   :application_url => 'http://twitter4r.rubyforge.org',
                   :source => 'twitter4r',
    }
    @@config = Twitter::Config.new(@@defaults)

    # Twitter::Client class methods
    class << self
      # Yields to given <tt>block</tt> to configure the Twitter4R API.
      def configure(&block)
        raise ArgumentError, "Block must be provided to configure" unless block_given?
        yield @@config
      end # configure
    end # class << self    
  end # Client class
end # Twitter module
