# client.rb contains the classes, methods and extends <tt>Twitter4R</tt> 
# features to define client calls to the Twitter REST API.

module Twitter #:nodoc:
  # Used to query or post to the Twitter REST API to simplify code.
  class Client
    include ClassUtilMixin
    
    @@URIS = {:public => '/statuses/public_timeline.json',
              :friends => '/statuses/friends_timeline.json',
              :friends_statues => '/statuses/friends.json',
              :followers => '/statuses/followers.json',
              :update => '/statuses/update.json',
              :send_direct_message => '/direct_messages/new.json', }

    class << self
      # Mostly helper method for irb shell prototyping
      # TODO: move this out as class extension for twitter4r console script
      def from_config(config_file, env = 'test')
        yaml_hash = YAML.load(File.read(config_file))
        self.new yaml_hash[env]
      end
    end # class << self

    def timeline(type = :public)
      http = create_connection
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
      http = create_connection
      http.start do |http|
        request = Net::HTTP::Post.new(uri, http_header)
        request.basic_auth(@login, @password)
        response = http.request(request, "status=#{URI.escape(message)}")
        handle_rest_response(response, uri)
      end
    end
    
    def send_direct_message(user, message)
      login = user.respond_to?(:screen_name) ? user.screen_name : user
      uri = @@URIS[:send_direct_message]
      http = create_connection
      http.start do |http|
        request = Net::HTTP::Post.new(uri, http_header)
        request.basic_auth(@login, @password)
        response = http.request(request, "user=#{login}&text=#{URI.escape(message)}")
        handle_rest_response(response, uri)
      end
    end

    protected
      attr_accessor :login, :password
      
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
        request = Net::HTTP::Get.new(uri, http_header)
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
      
      def create_connection
        conn = Net::HTTP.new(@@config.host, @@config.port, 
                             @@config.proxy_host, @@config.proxy_port)
        conn.use_ssl = true unless @@config.protocol != :ssl
        conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
        conn
      end

      def http_header
        @@header ||= { 'User-Agent' => "Twitter4R v#{Twitter::Version.to_version} [#{@@config.user_agent}]" }
        @@header
      end
  end
end
