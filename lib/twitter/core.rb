# The Twitter4R API provides a nicer Ruby object API to work with 
# instead of coding around the REST API.

require('net/https')
require('uri')
require('json')

# Encapsules the Twitter4R API.
module Twitter
  module ClassUtilMixin #:nodoc:
    def self.included(base)
      base.send(:include, InstanceMethods)
    end
    
    module InstanceMethods #:nodoc:
      def initialize(params = {})
        params.each do |key,val|
          self.send("#{key}=", val) if self.respond_to? key
        end
      end
    end
  end # ClassUtilMixin
  
  # Error subclass raised when there is an error encountered upon 
  # querying or posting to the REST API.
  class RESTError < Exception
    include ClassUtilMixin
    attr_accessor :code, :message, :uri
    
    def to_s
      "HTTP #{code}: #{message} at #{uri}"
    end
  end # RESTError

  # Represents a user of Twitter
  class User
    include ClassUtilMixin
    attr_accessor :id, :name, :description, :location, :screen_name, :url
    
    def eql?(obj)
      [:id, :name, :description, :location, 
      :screen_name, :url].each do |att|
        return false if self.send(att).eql?(obj.send(att))
      end or true
    end
  end # User
  
  # Represents a status posted to Twitter by a user of Twitter.
  class Status
    include ClassUtilMixin
    attr_accessor :id, :text, :created_at, :user

    def eql?(obj)
      [:id, :text, :created_at, :user].each do |att|
        return false if self.send(att).eql?(obj.send(att))
      end or true
    end
  end # Status

  # Used to query or post to the Twitter REST API to simplify code.
  class Client
    include ClassUtilMixin
    attr_accessor :login, :password
    
    @@HOST = 'twitter.com'
    @@PORT = 80
    @@SSL = false
    @@URIS = {:public => '/statuses/public_timeline.json',
              :friends => '/statuses/friends_timeline.json',
              :friends_statues => '/statuses/friends.json',
              :followers => '/statuses/followers.json',
              :update => '/statuses/update.json',
              :send_direct_message => '/direct_messages/new.json', }

    class << self
      def config(conf)
        @@HOST = conf[:host] if conf[:host]
        @@PORT = conf[:port] if conf[:port]
        @@SSL = conf[:use_ssl] if conf[:use_ssl] # getting ready for SSL support
      end
      
      # Mostly helper method for irb shell prototyping
      # TODO: move this out as class extension for twitter4r console script
      def from_config(config_file, env = 'test')
        yaml_hash = YAML.load(File.read(config_file))
        self.new yaml_hash[env]
      end
    end # class << self

    def timeline(type = :public)
      http = Net::HTTP.new(@@HOST, @@PORT)
      http.start do |http|
        timeline_request(type, http)
      end # http.start block
    end # timeline
    
    def public_timeline
      timeline :public
    end
    
    def friend_timeline
      timeline :friends
    end
    
    def friend_statuses
      timeline :friends_statuses
    end

    def follower_statuses
      timeline :followers
    end

    def update(message)
      uri = @@URIS[:update]
      http = Net::HTTP.new(@@HOST, @@PORT)
      http.start do |http|
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(@login, @password)
        response = http.request(request, "status=#{URI.escape(message)}")
        handle_rest_response(response, uri)
      end
    end
    
    def send_direct_message(user, message)
      login = user.respond_to?(:screen_name) ? user.screen_name : user
      uri = @@URIS[:send_direct_message]
      http = Net::HTTP.new(@@HOST, @@PORT)
      http.start do |http|
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(@login, @password)
        response = http.request(request, "user=#{login}&text=#{URI.escape(message)}")
        handle_rest_response(response, uri)
      end
    end

    protected
      attr_accessor :login, :password, :host, :port
      
      def unmarshall_statuses(status_array)
        status_array.collect do |status|
          Status.new(:id => status['id'], 
                     :text => status['text'],
                     :user => unmarshall_user(status['user']),
                     :created_at => Time.parse(status['created_at'])
                     )
        end      
      end
      
      def unmarshall_user(map)
        User.new(:id => map['id'], :name => map['name'],
                  :screen_name => map['screen_name'], 
                  :description => map['description'],
                  :location => map['location'],
                  :url => map['url'])
      end
      
      def timeline_request(type, http)
        uri = @@URIS[type]
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(@login, @password)
        response = http.request(request)

        handle_rest_response(response, uri)
        unmarshall_statuses(JSON.parse(response.body))
      end
      
      def raise_rest_error(response, uri = nil)
        raise RESTError.new(:code => response.code, 
                            :message => response.message,
                            :uri => uri)        
      end
      
      def handle_rest_response(response, uri)
        unless ["200", "201"].member?(response.code)
          raise_rest_error(response, uri)
        end
      end
  end
end
