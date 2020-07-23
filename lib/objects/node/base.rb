# frozen_string_literal: true

module Bcome::Node
  class Base
    include Bcome::Context
    include Bcome::WorkspaceCommands
    include Bcome::Node::Attributes
    include Bcome::WorkspaceMenu
    include Bcome::Node::LocalMetaDataFactory
    include Bcome::Node::RegistryManagement
    include Bcome::Tree

    def inspect
      "<##{self.class}: #{namespace} @network_driver=#{network_driver}>"
    end

    def self.const_missing(constant)
      ## Hook for direct access to node level resources by constant name where
      ## cd ServerName should yield the same outcome as cd "ServerName"
      set_context = ::IRB.CurrentContext.workspace.main
      set_context.resource_for_identifier(constant.to_s) ? constant.to_s : super
    end

    attr_reader :params

    DEFAULT_IDENTIFIER = 'bcome'

    include Bcome::LoadingBar::Handler

    def initialize(params)
      @params = params
      @identifier = nil
      @description = nil
      @views = params[:views]
      @parent = params[:parent]
      @type = params[:type]
      @metadata = {}
      @nodes_loaded = false

      set_view_attributes if @views
      validate_attributes

      @original_identifier = @identifier

      ::Bcome::Registry::Loader.instance.set_command_group_for_node(self)
    end

    attr_reader :parent

    attr_reader :views

    def method_missing(method_sym, *arguments)
      raise Bcome::Exception::Generic, "undefined method '#{method_sym}' for #{self.class}" unless method_is_available_on_node?(method_sym)

      if resource_identifiers.include?(method_sym.to_s)
        method_sym.to_s
      elsif command = user_command_wrapper.command_for_console_command_name(method_sym)
        command.execute(self, arguments)
      else
        raise NameError, "Missing method #{method_sym} for #{self.class}"
      end
    end

    def ssh_connect(params = {})
      ::Bcome::Ssh::Connector.connect(self, params)
    end

    def collection?
      false
    end

    def inventory?
      false
    end

    def server?
      false
    end

    def enabled_menu_items
      %i[ls lsa workon enable disable enable! disable! run tree ping put put_str rsync cd meta registry interactive execute_script]
    end

    def has_proxy?
      ssh_driver.has_proxy?
    end

    attr_writer :identifier

    def proxy
      ssh_driver.proxy
    end

    def proxy_chain
      ssh_driver.proxy_chain
    end

    def proxy_chain_link
      @proxy_chain_link ||= ::Bcome::Ssh::ProxyChainLink.new(self)
    end

    def scoped_resources
      # Active & not hidden
      resources.active.reject(&:hide?)
    end

    def scp(local_path, remote_path)
      scoped_resources.each do |resource|
        resource.put(local_path, remote_path)
      end
      nil
    end

    def rsync(local_path, remote_path)
      scoped_resources.each do |resource|
        resource.rsync(local_path, remote_path)
      end
      nil
    end

    def put(local_path, remote_path, connect = true)
      ssh_connect if connect # Initiate connect at highest namespace level

      scoped_resources.each do |resource|
        resource.put(local_path, remote_path, false)
      end
      nil
    end

    def put_str(string, remote_path, connect = true)
      ssh_connect if connect # Initiate connect at highest namespace level
      scoped_resources.pmap do |resource|
        resource.put_str(string, remote_path, false)
      end
      nil
    end

    def execute_script(script_name)
      results = {}
      machines.pmap do |machine|
        command = machine.execute_script(script_name)
        results[machine.namespace] = command
      end
      results
    end

    def hide?
      return true if @views.key?(:hidden) && @views[:hidden]

      false
    end

    def validate_attributes
      validate_identifier
      raise ::Bcome::Exception::MissingDescriptionOnView, views.inspect if requires_description? && !defined?(:description)
      raise ::Bcome::Exception::MissingTypeOnView, views.inspect if requires_type? && !defined?(:type)
    end

    def validate_identifier
      @identifier = DEFAULT_IDENTIFIER.dup if is_top_level_node? && !@identifier && !is_a?(::Bcome::Node::Server::Base)

      @identifier ||= "NO-ID_#{Time.now.to_i}".dup

      # raise ::Bcome::Exception::MissingIdentifierOnView.new(@views.inspect) unless @identifier
      @identifier.gsub!(/\s/, '_') # Remove whitespace
      @identifier.gsub!('-', '_') # change hyphens to undescores, hyphens don't play well in var names in irb

      # raise ::Bcome::Exception::InvalidIdentifier.new("'#{@identifier}' contains whitespace") if @identifier =~ /\s/
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
      #resources.any? # This was buggy:  an inventory may validly contain no resources. This does not mean that we haven't attempted to load them
      # we no explicitly set a flag for when we've loaded nodes. This will prevents uneccessary lookups over the wire
      @nodes_loaded
    end

    def nodes_loaded!
      @nodes_loaded = true
    end

    def resources
      @resources ||= ::Bcome::Node::Resources::Base.new
    end

    def list_key
      :view
    end

    def invoke(method_name, arguments = [])
      if method_is_available_on_node?(method_name)
        if respond_to?(method_name)
          # Invoke a method on node that's defined by the system
          begin
            if arguments&.any?
              send(method_name, *arguments)
            else
              send(method_name)
            end
          rescue ArgumentError => e
            raise ::Bcome::Exception::ArgumentErrorInvokingMethodFromCommmandLine, method_name + " error message - #{e.message}"
          end
        else
          # Invoke a user defined (registry) method
          command = user_command_wrapper.command_for_console_command_name(method_name.to_sym)
          command.execute(self, arguments)
        end
      else
        # Final crumb is neither a node level context nor an executable method on the penultimate node level context
        raise ::Bcome::Exception::InvalidBreadcrumb, "Method '#{method_name}' is not available on bcome node of type #{self.class}, at namespace #{namespace}"
      end
    end

    def resource_for_identifier(identifier)
      resources.for_identifier(identifier)
    end

    def recurse_resource_for_identifier(identifier)
      resource = resource_for_identifier(identifier)
      resource || (has_parent? ? parent.recurse_resource_for_identifier(identifier) : nil)
    end

    def prompt_breadcrumb
      "#{has_parent? ? "#{parent.prompt_breadcrumb}> " : ''}#{current_context? ? (has_parent? ? identifier.terminal_prompt : identifier) : identifier}"
    end

    def namespace
      "#{parent ? "#{parent.namespace}:" : ''}#{identifier}"
    end

    def keyed_namespace
      splits = namespace.split(':')
      splits[1..splits.size].join(':')
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

    def close_ssh_connections
      # For every loaded server, we'll close any lingering ssh connection
      if @resources&.any?
        resources.pmap do |resource|
          if resource.is_a?(::Bcome::Node::Server::Base)
            resource.close_ssh_connection
          else
            resource.close_ssh_connections
           end
        end
      end
      nil
    end

    def execute_local(command)
      puts "(local) > #{command}" unless ::Bcome::Orchestrator.instance.command_output_silenced?
      system(command)
      puts ''
    end

    def data_print_from_hash(data, heading)
      puts "\n#{heading.title}"
      puts ''

      if data.keys.any?
        data.each do |key, value|
          puts "#{key.to_s.resource_key}: #{value.to_s.informational}"
        end
      else
        puts 'No values found'.warning
      end
      puts ''
    end

    private

    def singleton_class
      class << self
        self
      end
    end

    def set_view_attributes
      @identifier = @views[:identifier]

      @views.keys.sort.each do |view_attribute_key|
        next if view_attributes_to_skip_on_setup.include?(view_attribute_key)

        next if view_attribute_key == :identifier

        singleton_class.class_eval do
          define_method(view_attribute_key) do
            @views[view_attribute_key]
          end
        end
      end
    end

    def view_attributes_to_skip_on_setup
      [:views]
    end

    private

    def to_ary
      # due to my method_missing implementation, the following is required.
      # with thanks to https://tenderlovemaking.com/2011/06/28/til-its-ok-to-return-nil-from-to_ary.html & http://yehudakatz.com/2010/01/02/the-craziest-fing-bug-ive-ever-seen/
      nil
    end
  end
end
