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

module Twitter
  class Console
    class << self
      @@OPTIONS = { :debugger => false, :config => "~/.twitter4r/accounts.yml" }
      def parse_options
        OptionParser.new do |opt|
          opt.banner = "Usage: t4rsh [environment] [options]"
          opt.on("--config=[~/.twitter4r/accounts.yml]", 'Use a specific config file.') { |v| @@OPTIONS[:config] = v }
          opt.parse!(ARGV)
        end
      end

      def config_file
        result = ENV["T4R_CONFIG"]
        file_name = File.expand_path('twitter.yml')
        result ||= file_name if File.exists?(file_name)
        file_name = File.expand_path('twitter.yml', 'config')
        result ||= file_name if File.exists?(file_name)
        file_name = File.expand_path('~/.twitter.yml')
        result ||= file_name if File.exists?(file_name)
        result
      end

      def account
        ENV["T4R_ENV"] || ENV["MERB_ENV"] || ENV["RAILS_ENV"]
      end

      def run(file)
        IRB.init_config(nil)
        IRB.conf[:USE_READLINE] = true
        IRB.conf[:PROMPT_MODE] = :SIMPLE
        IRB.start(file)
      end
    end
  end
end

