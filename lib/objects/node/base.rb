module Bcome::Node
  class Base

    include Bcome::Context
    include Bcome::WorkspaceCommands
    include Bcome::Node::Attributes
    include Bcome::WorkspaceMenu
    include Bcome::Node::MetaDataFactory
 
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
      @metadata = {}

      set_view_attributes if @views
      validate_attributes

      load_metadata
    end

    def enabled_menu_items
      [:ls, :lsa, :workon, :enable, :disable, :enable!, :disable!, :run, :interactive, :tree, :ping, :put, :cd, :reload!] 
    end

    def rewrite_estate_config   
      config = views
      config[:views] = []

      resources.active.each do |resource|
        config[:views] << resource.rewrite_estate_config
      end 

      config[:views].flatten! 
      config[:views].uniq!
      config
    end

    def has_proxy?
      ssh_driver.has_proxy?
    end

    def proxy
      ssh_driver.proxy
    end

    def put(local_path, remote_path)
      resources.active.each do |resource|
        resource.put(local_path, remote_path)
      end
      return
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
      resources.any?
    end
   
    def resources
      @resources ||= ::Bcome::Node::Resources::Base.new
    end

    def list_key
      :view
    end

    def invoke(method_name, arguments = [])
      if respond_to?(method_name)
        arity = self.class.instance_method(method_name).arity
        if arity == 0
          send(method_name)
        else
          number_of_arguments = arguments ? arguments.size : 0
          raise ::Bcome::Exception::MethodInvocationRequiresParameter.new "" if number_of_arguments == 0
          send(method_name, *arguments)
        end 
      else
        # Final crumb is neither a node level context nor an executable method on the penultimate node level context
        raise ::Bcome::Exception::InvalidBreadcrumb.new("Method '#{method_name}' is not available on bcome node of type #{self.class}, at namespace #{namespace}")
      end
    end

    def resource_for_identifier(identifier)
      resources.for_identifier(identifier)
    end

    def recurse_resource_for_identifier(identifier)
      resource = resource_for_identifier(identifier)
      return resource ? resource : (has_parent? ? parent.recurse_resource_for_identifier(identifier) : nil)
    end

    def prompt_breadcrumb
      "#{has_parent? ? "#{parent.prompt_breadcrumb}> " : "" }#{ is_current_context? ? (has_parent? ? identifier.terminal_prompt : identifier) : identifier}" 
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
