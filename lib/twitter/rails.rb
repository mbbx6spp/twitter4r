# File that contains extensions to the Twitter4R library directly related to providing
# seamless Rails integration.

require 'active_support'
#require 'active_support/core_ext'
require 'active_record/xml_serialization'

# Extend +String+ with +#xmlize+ method for convenience.
class String
  def xmlize
    # Forget module/namespace for now as this is totally broken in Rails 1.2.x 
    # (search for namespaced models on the Rails Trac site)
    cls = self.split('::').pop
    cls.dasherize.downcase
  end
end

# Parent mixin module that defines +InstanceMethods+ for Twitter4R model classes.
# 
# Defines/overrides the following methods for:
# * Twitter::RailsPatch::InstanceMethods#to_param
# * Twitter::RailsPatch::InstanceMethods#to_xml
# * Twitter::RailsPatch::InstanceMethods#to_json
module Twitter::RailsPatch
  class << self
    def included(base)
      base.send(:include, InstanceMethods)
      base.extend ClassMethods
    end

    module ClassMethods
      # Dummy method to satisfy ActiveRecord's XmlSerializer.
      def inheritance_column
        nil
      end
      
      # Returns Hash of name-column pairs
      def columns_hash
        {}
      end      
    end
    
    module InstanceMethods
      # Returns an Array of attribute names of the model
      def attribute_names
        self.class.class_eval("@@ATTRIBUTES").collect {|att| att.to_s }
      end
      
      # Override default +#to_param+ implementation.
      def to_param
        self.id.to_s
      end

      # Returns XML representation of model.      
      def to_xml(options = {})
        ActiveRecord::XmlSerializer.new(self, options.merge(:root => self.class.name.xmlize)).to_s
      end
      
      # Returns JSON representation of model.
      # 
      # The current implementation basically ignoring +options+, so reopen and override 
      # this implementation or live with it for the moment:)
      def to_json(options = {})
        JSON.unparse(self.to_hash)
      end
    end
  end
end

class Twitter::User
  include Twitter::RailsPatch
end

class Twitter::Status
  include Twitter::RailsPatch
end

class Twitter::Message
  include Twitter::RailsPatch
end

class Twitter::RESTError
  include Twitter::RailsPatch
  alias :id :code
  def to_hash
    { :code => @code, :message => @message, :uri => @uri }
  end
end

