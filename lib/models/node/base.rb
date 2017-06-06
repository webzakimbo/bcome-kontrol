module Bcome::Node
  class Base

    attr_reader :parent

    extend  Bcome::Node::Extensions

    include Bcome::Context
    include Bcome::WorkspaceCommands
    include Bcome::Node::Attributes
 
    DEFAULT_IDENTIFIER = "bcome"

    def self.const_missing(constant)
      ## Hook for direct access to node level resources by constant name where
      ## cd ServerName should yield the same outcome as cd "ServerName"
      set_context  = ::IRB.CurrentContext.workspace.main
      return (set_context.resource_for_identifier(constant.to_s)) ? constant.to_s : super
    end

    attr_reader :params

    def initialize(params)
      @params = params
      @identifier = nil
      @description = nil
      @views = params[:views]
      @parent = params[:parent]
      @type = params[:type]

      set_view_attributes if @views
      validate_attributes
    end

    def rewrite_estate_config   
      config = views
      resources.active.each do |resource|
        if config[:views]
          config[:views] << resource.rewrite_estate_config
        else
          config[:views] = [resource.rewrite_estate_config]
        end
      end 

      if config[:views]
        config[:views].flatten! 
        config[:views].uniq!
      end
      config
    end

    def cache!
       do_cache_inventories_in_memory
      ::Bcome::Node::Factory.instance.save_cache!
    end

    def do_cache_inventories_in_memory
      resources.each do |resource|        
        if resource.is_a?(Bcome::Node::Inventory)
          resource.cache_nodes_in_memory
        else
          resource.do_cache_inventories_in_memory 
        end
      end
    end

    def validate_attributes
      validate_identifier 
      raise ::Bcome::Exception::MissingDescriptionOnView.new(@views.inspect) if requires_description? && !@description
      raise ::Bcome::Exception::MissingTypeOnView.new(@views.inspect) if requires_type? && !@type
    end

    def validate_identifier
      @identifier = DEFAULT_IDENTIFIER if is_top_level_node? && !@identifier && !is_a?(::Bcome::Node::Server::Base)
      raise ::Bcome::Exception::MissingIdentifierOnView.new(@views.inspect) unless @identifier
      raise ::Bcome::Exception::InvalidIdentifier.new("'#{@identifier}' contains whitespace") if @identifier =~ /\s/
    end

    def has_dynamic_nodes?
      false
    end  

    def server?
      false
    end  

    def requires_description?
      true
    end

    def requires_type?
      true
    end

    def no_nodes?
      !resources || resources.empty?
    end

    def nodes_loaded?
      !has_dynamic_nodes? || @dynamic_nodes_loaded
    end
   
    def resources
      @resources ||= ::Bcome::Node::Resources::Base.new
    end

    def list_key
      :view
    end

    def invoke(method_name, command = nil)
      if respond_to?(method_name)
        if self.class.method_is_appropriate_for_command_line_invocation(method_name)
          unless command
            raise ::Bcome::Exception::MethodInvocationRequiresParameter.new("Calling '#{method_name}' at namespace #{namespace} requires a parameter")
          else
            send(method_name, command)
          end
        else
          send(method_name)
        end
      else
        # Final crumb is neither a node level context nor an executable method on the penultimate node level context
        raise ::Bcome::Exception::InvalidBreadcrumb.new("Method '#{method_name}' is not available on bcome node of type #{self.class}, at namespace #{namespace}")
      end
    end

    def resource_for_identifier(identifier)
      resources.for_identifier(identifier)
    end

    # TODO - test this
    # And then test in context of the ssh driver
    def recurse_resource_for_identifier(identifier)
      resource = resource_for_identifier(identifier)
      return resource ? resource : (has_parent? ? parent.recurse_resource_for_identifier(identifier) : nil)
    end

    def prompt_breadcrumb
      "#{has_parent? ? "#{parent.prompt_breadcrumb}> " : "" }#{ is_current_context? ? (has_parent? ? identifier.bc_cyan : identifier) : identifier}" 
    end

    def namespace
      "#{ parent ? "#{parent.namespace}:" : "" }#{identifier}"
    end

    def has_parent?
      !@parent.nil?
    end

    def is_top_level_node?
      !has_parent?
    end 

    def list_attributes
      { 
        "Identifier": :identifier,
        "Description": :description,
        "Type": :type
      }
    end

    def execute_local(command)
      puts "(local) > #{command}"
      system(command)
    end

    private

    def set_view_attributes
      @views.keys.each do |view_attribute_key|
        next if view_attributes_to_skip_on_setup.include?(view_attribute_key)
        instance_variable_set("@#{view_attribute_key}", @views[view_attribute_key])
      end
    end

    def view_attributes_to_skip_on_setup
      [:views] 
    end

  end
end
