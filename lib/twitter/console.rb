# Contains hooks for the twitter console

require('optparse')

module Twitter
  class Client
    class << self
      # Helper method mostly for irb shell prototyping.
      # 
      # Reads in login/password Twitter credentials from YAML file
      # found at the location given by <tt>config_file</tt> that has 
      # the following format:
      #  envname:
      #    login: mytwitterlogin
      #    password: mytwitterpassword
      # 
      # Where <tt>envname</tt> is the name of the environment like 'test', 
      # 'dev' or 'prod'.  The <tt>env</tt> argument defaults to 'test'.
      # 
      # To use this in the shell you would do something like the following 
      # examples:
      #  twitter = Twitter::Client.from_config('config/twitter.yml', 'dev')
      #  twitter = Twitter::Client.from_config('config/twitter.yml')
      def from_config(config_file, env = 'test')
        yaml_hash = YAML.load(File.read(config_file))
        self.new yaml_hash[env]
      end
    end # class << self
  end
end

