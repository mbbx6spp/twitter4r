# The Twitter4R API provides a nicer Ruby object API to work with 
# instead of coding around the REST API.

# Module to encapsule the Twitter4R API.
module Twitter
  # Mixin module for classes that need to have a constructor similar to
  # Rails' models, where a <tt>Hash</tt> is provided to set attributes
  # appropriately.
  # 
  # To define a class that uses this mixin, use the following code:
  #  class FilmActor
  #    include ClassUtilMixin
  #  end
  module ClassUtilMixin #:nodoc:
    def self.included(base) #:nodoc:
      base.send(:include, InstanceMethods)
    end
    
    # Instance methods defined for <tt>Twitter::ModelMixin</tt> module.
    module InstanceMethods #:nodoc:
      # Constructor/initializer that takes a hash of parameters that 
      # will initialize *members* or instance attributes to the 
      # values given.  For example,
      # 
      #  class FilmActor
      #    include Twitter::ClassUtilMixin
      #    attr_accessor :name
      #  end
      #  
      #  class Production
      #    include Twitter::ClassUtilMixin
      #    attr_accessor :title, :year, :actors
      #  end
      #  
      #  # Favorite actress...
      #  jodhi = FilmActor.new(:name => "Jodhi May")
      #  jodhi.name # => "Jodhi May"
      #  
      #  # Favorite actor...
      #  robert = FilmActor.new(:name => "Robert Lindsay")
      #  robert.name # => "Robert Lindsay"
      #  
      #  # Jane is also an excellent pick...gotta love her accent!
      #  jane = FilmActor.new(name => "Jane Horrocks")
      #  jane.name # => "Jane Horrocks"
      #  
      #  # Witty BBC series...
      #  mrs_pritchard = Production.new(:title => "The Amazing Mrs. Pritchard", 
      #                                 :year => 2005, 
      #                                 :actors => [jodhi, jane])
      #  mrs_pritchard.title  # => "The Amazing Mrs. Pritchard"
      #  mrs_pritchard.year   # => 2005
      #  mrs_pritchard.actors # => [#<FilmActor:0xb79d6bbc @name="Jodhi May">, 
      #  <FilmActor:0xb79d319c @name="Jane Horrocks">]
      #  # Any Ros Pritchard's out there to save us from the Tony Blair
      #  # and Gordon Brown *New Labour* debacle?  You've got my vote! 
      #  
      #  jericho = Production.new(:title => "Jericho", 
      #                           :year => 2005, 
      #                           :actors => [robert])
      #  jericho.title   # => "Jericho"
      #  jericho.year    # => 2005
      #  jericho.actors  # => [#<FilmActor:0xc95d3eec @name="Robert Lindsay">]
      # 
      # Assuming class <tt>FilmActor</tt> includes 
      # <tt>Twitter::ClassUtilMixin</tt> in the class definition 
      # and has an attribute of <tt>name</tt>, then that instance 
      # attribute will be set to "Jodhi May" for the <tt>actress</tt> 
      # object during object initialization (aka construction for 
      # you Java heads).
      def initialize(params = {})
        params.each do |key,val|
          self.send("#{key}=", val) if self.respond_to? key
        end
        self.send(:init) if self.respond_to? :init
      end
      
      protected
        # Helper method to provide an easy and terse way to require 
        # a block is provided to a method.
        def require_block(block_given)
          raise ArgumentError, "Must provide a block" unless block_given
        end
    end
  end # ClassUtilMixin
  
  # Exception subclass raised when there is an error encountered upon 
  # querying or posting to the remote Twitter REST API.
  # 
  # To consume and query any <tt>RESTError</tt> raised by Twitter4R:
  #  begin
  #    # Do something with your instance of <tt>Twitter::Client</tt>.
  #    # Maybe something like:
  #    timeline = twitter.timeline_for(:public)
  #  rescue RESTError => re
  #    puts re.code, re.message, re.uri
  #  end
  # Which on the code raising a <tt>RESTError</tt> will output something like:
  #  404
  #  Resource Not Found
  #  /i_am_crap.json
  class RESTError < Exception
    include ClassUtilMixin
    @@ATTRIBUTES = [:code, :message, :uri]
    attr_accessor :code, :message, :uri
    
    # Returns string in following format:
    #  "HTTP #{@code}: #{@message} at #{@uri}"
    # For example,
    #  "HTTP 404: Resource Not Found at /i_am_crap.json"
    def to_s
      "HTTP #{@code}: #{@message} at #{@uri}"
    end
  end # RESTError
  
  # Remote REST API interface representation
  # 
  class RESTInterfaceSpec
  	include ClassUtilMixin
  	
  end
  
  # Remote REST API method representation
  # 
  class RESTMethodSpec
  	include ClassUtilMixin
  	attr_accessor :uri, :method, :parameters
  end
  
  # Remote REST API method parameter representation
  # 
  class RESTParameterSpec
  	include ClassUtilMixin
  	attr_accessor :name, :type, :required
  	def required?; @required; end
  end
end
