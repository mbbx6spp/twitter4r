dir = File.dirname(__FILE__)

require File.expand_path("#{dir}/dsl/ivar_proxy")
require File.expand_path("#{dir}/dsl/assigns_hash_proxy")
require File.expand_path("#{dir}/dsl/behaviour")

module Spec
  module Rails
    # Spec::Rails::DSL extends Spec::DSL (RSpec's core DSL module) to provide
    # Rails-specific contexts for spec'ing Rails Models, Views, Controllers and Helpers.
    #
    # == Model Specs
    #
    # These are the equivalent of unit tests in Rails' built in testing. Ironically (for the traditional TDD'er) these are the only specs that we feel should actually interact with the database.
    #
    # See Spec::Rails::DSL::ModelBehaviour
    #
    # == Controller Specs
    #
    # These align somewhat with functional tests in rails, except that they do not actually render views (though you can force rendering of views if you prefer). Instead of setting expectations about what goes on a page, you set expectations about what templates get rendered.
    #
    # See Spec::Rails::DSL::ControllerBehaviour
    #
    # == View Specs
    #
    # This is the other half of Rails functional testing. View specs allow you to set up assigns and render
    # a template. By assigning mock model data, you can specify view behaviour with no dependency on a database
    # or your real models.
    #
    # See Spec::Rails::DSL::ViewBehaviour
    #
    # == Helper Specs
    #
    # These let you specify directly methods that live in your helpers.
    #
    # See Spec::Rails::DSL::HelperBehaviour
    module DSL
    end
  end
end
