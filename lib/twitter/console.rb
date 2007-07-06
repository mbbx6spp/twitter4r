# Contains hooks for the twitter console

module Twitter
  class Client
    class << self
      # Mostly helper method for irb shell prototyping
      # TODO: move this out as class extension for twitter4r console script
      def from_config(config_file, env = 'test')
        yaml_hash = YAML.load(File.read(config_file))
        self.new yaml_hash[env]
      end
    end # class << self
  end
end
