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

    def initialize(params)
      @identifier = nil
      @description = nil
      @raw_view_data = params[:view_data]
      @parent = params[:parent]
      @type = params[:type]

      set_view_attributes if @raw_view_data

      validate_identifier
      raise ::Bcome::Exception::MissingDescriptionOnView.new(@raw_view_data.inspect) unless @description
      raise ::Bcome::Exception::MissingTypeOnView.new(@raw_view_data.inspect) unless @type
    end

    def validate_identifier
      @identifier = DEFAULT_IDENTIFIER if is_top_level_node? && !@identifier
      raise ::Bcome::Exception::MissingIdentifierOnView.new(@raw_view_data.inspect) unless @identifier
      raise ::Bcome::Exception::InvalidIdentifier.new(@identifier) if @identifier =~ /\s/
    end

    def has_dynamic_nodes?
      false
    end  

    def nodes_loaded?
      !has_dynamic_nodes? || @dynamic_nodes_loaded
    end
   
    def resources
      @resources ||= ::Bcome::Node::Resources.new
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

    def prompt_breadcrumb
      "#{has_parent? ? "#{parent.prompt_breadcrumb}> " : "" }#{ is_current_context? ? identifier.cyan : identifier}"
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

    private

    def set_view_attributes
      @raw_view_data.keys.each do |view_attribute_key|
        next if view_attributes_to_skip_on_setup.include?(view_attribute_key)
        instance_variable_set("@#{view_attribute_key}", @raw_view_data[view_attribute_key])
      end
    end

    def view_attributes_to_skip_on_setup
      [:views] 
    end

  end
end
