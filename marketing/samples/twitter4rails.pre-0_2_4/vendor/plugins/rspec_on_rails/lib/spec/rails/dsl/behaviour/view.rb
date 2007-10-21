module Spec
  module Rails
    module DSL
      module ViewBehaviourHelpers
        class << self
          def included(mod)
            mod.send :include, ExampleMethods
          end
        end
        
        module ExampleMethods
          # Renders a template for a View Spec, which then provides access to the result
          # through the +response+.
          # 
          # == Examples
          # 
          #   render('/people/list')
          #   render('/people/list', :helper => MyHelper)
          #   render('/people/list', :helpers => [MyHelper, MyOtherHelper])
          #   render(:partial => '/people/_address')
          #
          # See Spec::Rails::DSL::ViewBehaviour for more information.
          def render(*args)
            options = Hash === args.last ? args.pop : {}
            options[:template] = args.first.to_s unless args.empty?

            set_base_view_path(options)
            add_helpers(options)

            assigns[:action_name] = @action_name

            @request.path_parameters = {
              :controller => derived_controller_name(options),
              :action => derived_action_name(options)
            }

            defaults = { :layout => false }
            options = defaults.merge options

            @controller.instance_variable_set :@params, @request.parameters
            
            @controller.send :initialize_current_url

            @controller.class.instance_eval %{
              def controller_path
                "#{derived_controller_name(options)}"
              end
            }

            @controller.send :forget_variables_added_to_assigns
            @controller.send :render, options
            @controller.send :process_cleanup
          end
          
          # This provides the template. Use this to set mock
          # expectations for dealing with partials
          #
          # == Example
          #
          #   describe "/person/new" do
          #     it "should use the form partial" do
          #       template.should_receive(:render).with(:partial => 'form')
          #       render "/person/new"
          #     end
          #   end
          def template
            @controller.template
          end
        end
      end

      class ViewExampleController < ActionController::Base #:nodoc:
        attr_reader :template

        def add_helper_for(template_path)
          add_helper(template_path.split('/')[0])
        end

        def add_helper(name)
          begin
            helper_module = "#{name}_helper".camelize.constantize
          rescue
            return
          end
          template.metaclass.class_eval do
            include helper_module
          end
        end
      
      end
      
      class ViewEvalContext < Spec::Rails::DSL::FunctionalEvalContext
        include Spec::Rails::DSL::ViewBehaviourHelpers
        def setup #:nodoc:
          super
          # these go here so that flash and session work as they should.
          @controller.send :initialize_template_class, @response
          @controller.send :assign_shortcuts, @request, @response
          @session = @controller.session
          @controller.class.send :public, :flash # make flash accessible to the spec
        end
      
        def teardown #:nodoc:
          super
          #necessary to ensure that base_view_path is not set across contexts
          ActionView::Base.base_view_path = nil
        end

        def set_base_view_path(options) #:nodoc:
          ActionView::Base.base_view_path = base_view_path(options)
        end

        def base_view_path(options) #:nodoc:
          "/#{derived_controller_name(options)}/"
        end

        def derived_controller_name(options) #:nodoc:
          parts = subject_of_render(options).split('/').reject { |part| part.empty? }
          "#{parts[0..-2].join('/')}"
        end
      
        def derived_action_name(options) #:nodoc:
          parts = subject_of_render(options).split('/').reject { |part| part.empty? }
          "#{parts.last}"
        end
      
        def subject_of_render(options) #:nodoc:
          [:template, :partial, :file].each do |render_type|
            if options.has_key?(render_type)
              return options[render_type]
            end
          end
          raise Exception.new("Unhandled render type in view spec.")
        end
      
        def add_helpers(options) #:nodoc:
          @controller.add_helper("application")
          @controller.add_helper(derived_controller_name(options))
          @controller.add_helper(options[:helper]) if options[:helper]
          options[:helpers].each { |helper| @controller.add_helper(helper) } if options[:helpers]
        end


      end

      # View Specs live in $RAILS_ROOT/spec/views/.
      #
      # View Specs use Spec::Rails::DSL::ViewBehaviour,
      # which provides access to views without invoking any of your controllers.
      # See Spec::Rails::Expectations::Matchers for information about specific
      # expectations that you can set on views.
      #
      # == Example
      #
      #   describe "login/login" do
      #     before do
      #       render 'login/login'
      #     end
      # 
      #     it "should display login form" do
      #       response.should have_tag("form[action=/login]") do
      #         with_tag("input[type=text][name=email]")
      #         with_tag("input[type=password][name=password]")
      #         with_tag("input[type=submit][value=Login]")
      #       end
      #     end
      #   end
      class ViewBehaviour < Spec::DSL::Behaviour
        def execution_context(specification=nil) # :nodoc:
          instance = execution_context_class.new(specification)
          instance.instance_eval { @controller_class_name = "Spec::Rails::DSL::ViewExampleController" }
          instance
        end
        def before_eval # :nodoc:
          inherit Spec::Rails::DSL::ViewEvalContext
          prepend_before {setup}
          append_after {teardown}
          configure
        end

        Spec::DSL::BehaviourFactory.add_behaviour_class(:view, self)
      end
    end
  end
end
