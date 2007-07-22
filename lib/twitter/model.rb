# Contains Twitter4R Model API.

module Twitter
  # Mixin module for model classes.  Includes generic class methods like
  # unmarshal.
  # 
  # To create a new model that includes this mixin's features simply:
  #  class NewModel
  #    include Twitter::ModelMixin
  #  end
  # 
  # This mixin module automatically includes <tt>Twitter::ClassUtilMixin</tt>
  # features.
  # 
  # The contract for models to use this mixin correctly is that the class 
  # including this mixin must provide an class method named <tt>attributes</tt>
  # that will return an Array of attribute symbols that will be checked 
  # in #eql? override method.  The following would be sufficient:
  #  def self.attributes; @@ATTRIBUTES; end
  module ModelMixin #:nodoc:
    def self.included(base) #:nodoc:
      base.send(:include, Twitter::ClassUtilMixin)
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
    end

    # Class methods defined for <tt>Twitter::ModelMixin</tt> module.
    module ClassMethods #:nodoc:
      # Unmarshal object singular or plural array of model objects
      # from JSON serialization.  Currently JSON is only supported 
      # since this is all <tt>Twitter4R</tt> needs.
      def unmarshal(raw)
        input = JSON.parse(raw)
        def unmarshal_model(hash)
          self.new(hash)
        end
        return unmarshal_model(input) if input.is_a?(Hash) # singular case
        result = []
        input.each do |hash|
          model = unmarshal_model(hash) if hash.is_a?(Hash)
          result << model
        end if input.is_a?(Array)
        result # plural case
      end
    end
    
    # Instance methods defined for <tt>Twitter::ModelMixin</tt> module.
    module InstanceMethods #:nodoc:
      attr_accessor :client
      # Equality method override of Object#eql? default.
      # 
      # Relies on the class using this mixin to provide a <tt>attributes</tt>
      # class method that will return an Array of attributes to check are 
      # equivalent in this #eql? override.
      # 
      # It is by design that the #eql? method will raise a NoMethodError
      # if no <tt>attributes</tt> class method exists, to alert you that 
      # you must provide it for a meaningful result from this #eql? override.
      # Otherwise this will return a meaningless result.
      def eql?(other)
        attrs = self.class.attributes
        attrs.each do |att|
          return false unless self.send(att).eql?(other.send(att))
        end
        true
      end
      
      # Returns integer representation of model object instance.
      # 
      # For example,
      #  status = Twitter::Status.new(:id => 234343)
      #  status.to_i #=> 234343
      def to_i
        @id
      end
      
      # Returns string representation of model object instance.
      # 
      # For example,
      #  status = Twitter::Status.new(:text => 'my status message')
      #  status.to_s #=> 'my status message'
      # 
      # If a model class doesn't have a @text attribute defined 
      # the default Object#to_s will be returned as the result.
      def to_s
        self.respond_to?(:text) ? @text : super.to_s
      end
      
      # Returns hash representation of model object instance.
      # 
      # For example,
      #  u = Twitter::User.new(:id => 2342342, :screen_name => 'tony_blair_is_the_devil')
      #  u.to_hash #=> {:id => 2342342, :screen_name => 'tony_blair_is_the_devil'}
      # 
      # This method also requires that the class method <tt>attributes</tt> be 
      # defined to return an Array of attributes for the class.
      def to_hash
        attrs = self.class.attributes
        result = {}
        attrs.each do |att|
          value = self.send(att)
          value = value.to_hash if value.respond_to?(:to_hash)
          result[att] = value if value
        end
        result
      end
      
      # "Blesses" model object.
      # 
      # Should be overridden by model class if special behavior is expected
      # 
      # Expected to return blessed object (usually <tt>self</tt>)
      def bless(client)
        self.basic_bless(client)
      end
      
      protected
        # Basic "blessing" of model object 
        def basic_bless(client)
          self.client = client
          self
        end
    end
  end
  
  module AuthenticatedUserMixin
  	def self.included(base)
  		base.send(:include, InstanceMethods)
  	end
  	
  	module InstanceMethods
      # Returns an Array of user objects that represents the authenticated
      # user's friends on Twitter.
      def followers
        @client.my(:followers)
      end
      
      # Adds given user as a friend.  Returns user object as given by 
      # <tt>Twitter</tt> REST server response.
      # 
      # For <tt>user</tt> argument you may pass in the unique integer 
      # user ID, screen name or Twitter::User object representation.
      def befriend(user)
      	@client.friend(:add, user)
      end
      
      # Removes given user as a friend.  Returns user object as given by 
      # <tt>Twitter</tt> REST server response.
      # 
      # For <tt>user</tt> argument you may pass in the unique integer 
      # user ID, screen name or Twitter::User object representation.
      def defriend(user)
      	@client.friend(:remove, user)
      end
  	end
  end

  # Represents a <tt>Twitter</tt> user
  class User
    include ModelMixin
    @@ATTRIBUTES = [:id, :name, :description, :location, :screen_name, :url, :profile_image_url, :protected]
    attr_accessor *@@ATTRIBUTES

    class << self
      # Used as factory method callback
      def attributes; @@ATTRIBUTES; end

      # Returns user model object with given <tt>id</tt> using the configuration
      # and credentials of the <tt>client</tt> object passed in.
      # 
      # You can pass in either the user's unique integer ID or the user's 
      # screen name.
      def find(id, client)
        client.user(id)
      end
    end
    
    # Override of ModelMixin#bless method.
    # 
    # Adds #followers instance method when user object represents 
    # authenticated user.  Otherwise just do basic bless.
    # 
    # This permits applications using <tt>Twitter4R</tt> to write 
    # Rubyish code like this:
    #  followers = user.followers if user.is_me?
    # Or:
    #  followers = user.followers if user.respond_to?(:followers)
    def bless(client)
      basic_bless(client)
      self.instance_eval(%{
      	self.class.send(:include, Twitter::AuthenticatedUserMixin)
      }) if self.is_me? and not self.respond_to?(:followers)
      self
    end
    
    # Returns whether this <tt>Twitter::User</tt> model object
    # represents the authenticated user of the <tt>client</tt>
    # that blessed it.
    def is_me?
      # TODO: Determine whether we should cache this or not?
      # Might be dangerous to do so, but do we want to support
      # the edge case where this would cause a problem?  i.e. 
      # changing authenticated user after initial use of 
      # authenticated API.
      # TBD: To cache or not to cache.  That is the question!
      # Since this is an implementation detail we can leave this for 
      # subsequent 0.2.x releases.  It doesn't have to be decided before 
      # the 0.2.0 launch.
      @screen_name == @client.instance_eval("@login")
    end
    
    # Returns an Array of user objects that represents the authenticated
    # user's friends on Twitter.
    def friends
      @client.user(@id, :friends)
    end
  end # User
  
  # Represents a status posted to <tt>Twitter</tt> by a <tt>Twitter</tt> user.
  class Status
    include ModelMixin
    @@ATTRIBUTES = [:id, :text, :created_at, :user]
    attr_accessor *@@ATTRIBUTES

    class << self
      # Used as factory method callback
      def attributes; @@ATTRIBUTES; end
      
      # Returns status model object with given <tt>status</tt> using the 
      # configuration and credentials of the <tt>client</tt> object passed in.
      def find(id, client)
        client.status(:get, id)
      end
      
      # Creates a new status for the authenticated user of the given 
      # <tt>client</tt> context.
      # 
      # You MUST include a valid/authenticated <tt>client</tt> context 
      # in the given <tt>params</tt> argument.
      # 
      # For example:
      #  status = Twitter::Status.create(
      #    :text => 'I am shopping for flip flops',
      #    :client => client)
      # 
      # An <tt>ArgumentError</tt> will be raised if no valid client context
      # is given in the <tt>params</tt> Hash.  For example,
      #  status = Twitter::Status.create(:text => 'I am shopping for flip flops')
      # The above line of code will raise an <tt>ArgumentError</tt>.
      # 
      # The same is true when you do not provide a <tt>:text</tt> key-value
      # pair in the <tt>params</tt> argument given.
      # 
      # The Twitter::Status object returned after the status successfully
      # updates on the Twitter server side is returned from this method.
      def create(params)
      	client, text = params[:client], params[:text]
      	raise ArgumentError, 'Valid client context must be provided' unless client.is_a?(Twitter::Client)
      	raise ArgumentError, 'Must provide text for the status to update' unless text.is_a?(String)
      	client.status(:post, text)
      end
    end
    
    protected
      # Constructor callback
      def init
        @user = User.new(@user) if @user.is_a?(Hash)
        @created_at = Time.parse(@created_at) if @created_at.is_a?(String)
      end    
  end # Status
  
  # Represents a direct message on <tt>Twitter</tt> between <tt>Twitter</tt> users.
  class Message
    include ModelMixin
    @@ATTRIBUTES = [:id, :recipient, :sender, :text, :created_at]
    attr_accessor *@@ATTRIBUTES
    
    class << self
      # Used as factory method callback
      def attributes; @@ATTRIBUTES; end
      
      # Raises <tt>NotImplementedError</tt> because currently 
      # <tt>Twitter</tt> doesn't provide a facility to retrieve 
      # one message by unique ID.
      def find(id, client)
        raise NotImplementedError, 'Twitter has yet to implement a REST API for this.  This is not a Twitter4R library limitation.'
      end
      
      # Creates a new direct message from the authenticated user of the 
      # given <tt>client</tt> context.
      # 
      # You MUST include a valid/authenticated <tt>client</tt> context 
      # in the given <tt>params</tt> argument.
      # 
      # For example:
      #  status = Twitter::Message.create(
      #    :text => 'I am shopping for flip flops',
      #    :receipient => 'anotherlogin',
      #    :client => client)
      # 
      # An <tt>ArgumentError</tt> will be raised if no valid client context
      # is given in the <tt>params</tt> Hash.  For example,
      #  status = Twitter::Status.create(:text => 'I am shopping for flip flops')
      # The above line of code will raise an <tt>ArgumentError</tt>.
      # 
      # The same is true when you do not provide any of the following
      # key-value pairs in the <tt>params</tt> argument given:
      # * <tt>text</tt> - the String that will be the message text to send to <tt>user</tt>
      # * <tt>recipient</tt> - the user ID, screen_name or Twitter::User object representation of the recipient of the direct message
      # 
      # The Twitter::Message object returned after the direct message is 
      # successfully sent on the Twitter server side is returned from 
      # this method.
      def create(params)
      	client, text, recipient = params[:client], params[:text], params[:recipient]
      	raise ArgumentError, 'Valid client context must be given' unless client.is_a?(Twitter::Client)
      	raise ArgumentError, 'Message text must be supplied to send direct message' unless text.is_a?(String)
      	raise ArgumentError, 'Recipient user must be specified to send direct message' unless [Twitter::User, Integer, String].member?(recipient.class)
      	client.message(:post, text, recipient)
      end
    end
    
    protected
      # Constructor callback
      def init
        @sender = User.new(@sender) if @sender.is_a?(Hash)
        @recipient = User.new(@recipient) if @recipient.is_a?(Hash)
        @created_at = Time.parse(@created_at) if @created_at.is_a?(String)
      end
  end # Message
end # Twitter
