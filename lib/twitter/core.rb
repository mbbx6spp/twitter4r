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
      # Constructor/initializer that takes a hash of parameters that will initialize *members* or instance 
      # attributes to the values given.  For example,
      #  c = FilmActor.new(:name => "Jodhi May")
      #  c.name # => "Jodhi May"
      # Assuming FilmActor includes <tt>Twitter::ClassUtilMixin</tt> in the class definition, the name 
      # instance attribute will be set to "Jodhi May" for the <tt>c</tt> object.
      def initialize(params = {})
        params.each do |key,val|
          self.send("#{key}=", val) if self.respond_to? key
        end
        self.send(:init) if self.respond_to? :init
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
        return false unless self.send(att).eql?(obj.send(att))
      end or true
    end
  end # User
  
  # Represents a status posted to Twitter by a user of Twitter.
  class Status
    include ClassUtilMixin
    attr_accessor :id, :text, :created_at, :user
    
    def eql?(obj)
      [:id, :text, :created_at, :user].each do |att|
        return false unless self.send(att).eql?(obj.send(att))
      end
    end
    
    protected
      # Constructor callback
      def init
        @created_at = Time.parse(@created_at) if @created_at.is_a?(String)
      end    
  end # Status
end
