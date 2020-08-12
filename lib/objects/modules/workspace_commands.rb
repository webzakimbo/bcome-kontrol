e frozen_string_literal: true

module Bcome
  module WorkspaceCommands
    def ssh_connect(params = {})
      ::Bcome::Ssh::Connector.connect(self, params)
    end

    def ls(node = self, active_only = false)
      if node != self && (resource = resources.for_identifier(node))
        resource.send(:ls, active_only)
      else
        puts "\n\n" + visual_hierarchy.hierarchy + "\n"
        puts "\t" + "Available #{list_key}s:" + "\n\n"

        iterate_over = active_only ? resources.active : resources

        if iterate_over.any?

          iterate_over.sort_by(&:identifier).each do |resource|
            next if resource.hide?

            is_active = resources.is_active_resource?(resource)
            puts resource.pretty_description(is_active)

            puts "\n"
          end
        else
          puts "\tNo resources found".informational
        end

        new_line
        nil
      end
    end

    def lsa
      show_active_only = true
      ls(self, show_active_only)
    end

    def interactive
      ::Bcome::Interactive::Session.run(self, :interactive_ssh)
    end

    def parents
      ps = []
      ps << [parent, parent.parents] if has_parent?
      ps.flatten
    end

    def cd(identifier)
      if (resource = resources.for_identifier(identifier))
        if resource.parent.resources.is_active_resource?(resource)
          ::Bcome::Workspace.instance.set(current_context: self, context: resource)
        else
          puts "\nCannot enter context - #{identifier} is disabled. To enable enter 'enable #{identifier}'\n".error
        end
      else
        raise Bcome::Exception::InvalidBreadcrumb, "Cannot find a node named '#{identifier}'"
        puts "#{identifier} not found"
      end
    end

    def run(*raw_commands)
      raise Bcome::Exception::MethodInvocationRequiresParameter, "Please specify commands when invoking 'run'" if raw_commands.empty?

      results = {}

      ssh_connect(show_progress: true)

      machines.pmap do |machine|
        commands = machine.do_run(raw_commands)
        results[machine.namespace] = commands
      end
      results
    end

    def ping
      ssh_connect(is_ping: true, show_progress: true)
    end

    def pretty_description(is_active = true)
      desc = ''
      list_attributes.each do |key, value|
        next unless respond_to?(value) || instance_variable_defined?("@#{value}")

        attribute_value = send(value)
        next unless attribute_value

        desc += "\t"
        desc += is_active ? key.to_s.resource_key : key.to_s.resource_key_inactive
        desc += "\s" * (12 - key.length)
        desc += is_active ? attribute_value.resource_value : attribute_value.resource_value_inactive
        desc += "\n"
        desc = desc unless is_active
      end
      desc
    end

    def disable(*ids)
      ids.each { |id| resources.do_disable(id) }
    end

    def enable(*ids)
      ids.each { |id| resources.do_enable(id) }
    end

    def clear!
      # Clear any disabled selection at this level and at all levels below
      resources.clear!
      resources.each(&:clear!)
      nil
    end

    def workon(*ids)
      resources.disable!
      ids.each { |id| resources.do_enable(id) }
      puts "\nYou are now working on '#{ids.join(', ')}\n".informational
    end

    def disable!
      resources.disable!
      resources.each(&:disable!)
      nil
    end

    def enable!
      resources.enable!
      resources.each(&:enable!)
      nil
    end

    ## Helpers --

    def resource_identifiers
      resources.collect(&:identifier)
    end

    def is_node_level_method?(method_sym)
      respond_to?(method_sym) || method_is_available_on_node?(method_sym)
    end

    def method_in_registry?(method_sym)
      ::Bcome::Registry::CommandList.instance.command_in_list?(self, method_sym)
    end

    def method_is_available_on_node?(method_sym)
      resource_identifiers.include?(method_sym.to_s) || method_in_registry?(method_sym) || respond_to?(method_sym) || instance_variable_defined?("@#{method_sym}")
    end

    def visual_hierarchy
      tabs = 0
      hierarchy = ''
      tree_descriptions.each do |d|
        hierarchy += "#{"\s\s\s" * tabs}|- #{d}\n"
        tabs += 1
      end
      hierarchy
    end

    def tree_descriptions
      d = parent ? parent.tree_descriptions + [description] : [description]
      d.flatten
    end

    def new_line
      puts "\n"
    end
  end
end
