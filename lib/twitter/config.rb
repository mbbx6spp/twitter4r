# config.rb contains classes, methods and extends existing Twitter4R classes 
# to provide easy configuration facilities.

module Twitter #:nodoc:
  # Represents global configuration for Twitter::Client.
  # Can override the following configuration options:
  # * <tt>protocol</tt> - <tt>:http</tt>, <tt>:https</tt> or <tt>:ssl</tt> supported.  <tt>:ssl</tt> is an alias for <tt>:https</tt>.  Defaults to <tt>:ssl</tt>
  # * <tt>host</tt> - hostname to connect to for the Twitter service.  Defaults to <tt>'twitter.com'</tt>.
  # * <tt>port</tt> - port to connect to for the Twitter service.  Defaults to <tt>443</tt>.
  class Config
    include ClassUtilMixin
    @@ATTRIBUTES = [:protocol, :host, :port, :proxy_host, :proxy_port, :user_agent]
    attr_accessor *@@ATTRIBUTES
    
    # Override of #eql? to ensure RSpec specifications run correctly.
    # Also done to follow Ruby best practices.
    def eql?(other)
      return true if self == other
      @@ATTRIBUTES.each do |att|
        return false unless self.send(att).eql?(other.send(att))
      end
      true
    end
  end

  class Client #:nodoc:
    @@defaults = { :host => 'twitter.com', 
                   :port => 443, 
                   :protocol => :ssl,
                   :proxy_host => nil,
                   :proxy_port => nil,
                   :user_agent => "default",
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
