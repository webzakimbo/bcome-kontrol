module Bcome::WorkspaceCommands
  def ls
    puts "\n\n" + visual_hierarchy.bc_orange + "\n"
    puts "\tAvailable #{list_key}s: ".bc_cyan + "\n\n"

    @resources.sort_by(&:identifier).each do |resource|
      is_active = @resources.is_active_resource?(resource)
      puts resource.pretty_description(is_active)
      puts "\n"
    end
    new_line
    nil
  end

  def tree
    puts "\nTree view\n".green
    tab = ''
    parents.reverse.each do |p|
      print_tree_view_for_resource(tab, p)
      tab = "#{tab}\t"
    end
    print_tree_view_for_resource(tab, self)
    list_in_tree("#{tab}\t", resources)
    print "\n"
  end

  def parents
    ps = []
    ps << [parent, parent.parents] if has_parent?
    ps.flatten
  end

  def list_in_tree(tab, resources)
    resources.sort_by(&:identifier).each do |resource|
      unless resource.parent && !(resource.parent.resources.is_active_resource?(resource))
        silent = true
        resource.load_dynamic_nodes(silent) unless resource.nodes_loaded?
        print_tree_view_for_resource(tab, resource)
        list_in_tree("#{tab}\t", resource.resources) 
      end
    end
  end

  def print_tree_view_for_resource(tab, resource)
    separator = resource.server? ? "*" : "-"
    tree_item = tab.to_s + separator.cyan + " #{resource.type.cyan.underline} \s#{resource.identifier.yellow}"
    tree_item += " (empty set)" if !resource.server? && !resource.resources.has_active_nodes?
    puts tree_item
  end

  def cd(identifier)
    if resource = resources.for_identifier(identifier)
      if resource.parent.resources.is_active_resource?(resource) 
        ::Bcome::Workspace.instance.set(current_context: self, context: resource)
      else
        puts "\nCannot enter context - #{identifier} is disabled. To enable enter 'enable #{identifier}'\n".green
      end
    else
      raise Bcome::Exception::InvalidBreadcrumb, "Cannot find a node named '#{identifier}'"
      puts "#{identifier} not found"
    end
  end

  def interactive
    ::Bcome::Interactive::Session.run(self)
  end

  def run(raw_commands)
    machines.pmap do |machine|
      machine.do_run(raw_commands)
    end
    nil
  end

  def ping
    machines.pmap(&:ping)
  end

  def pretty_description(is_active = true)
    desc = ''
    list_attributes.each do |key, value|
      next unless respond_to?(value) || instance_variable_defined?("@#{value}")
      attribute_value = send(value)
      next unless attribute_value

      desc += "\t"
      desc += is_active ? key.to_s.bc_cyan : key.to_s
      desc += "\s" * (12 - key.length)
      attribute_value = value == :identifier ? attribute_value.underline : attribute_value
      desc += is_active ? attribute_value.bc_green : attribute_value
      desc += "\n"
      desc = desc unless is_active
    end
    desc
  end

  def back
    exit
  end

  def disable(identifier)
    resources.do_disable(identifier)
  end

  def enable(identifier)
    resources.do_enable(identifier)
  end

  def clear!
    # Clear any disabled selection at this level and at all levels below
    resources.clear!
    resources.each {|r| r.clear! }
    nil
  end

  def disable!
    resources.disable!
    resources.each {|r| r.disable! }
    nil
  end

  def enable!
    resources.enable!
    resources.each {|r| r.enable! }
    nil
  end

  ## Helpers --

  def resource_identifiers
    resources.collect(&:identifier)
  end

  def method_missing(method_sym, *arguments, &block)
    if resource_identifiers.include?(method_sym.to_s)
      method_sym.to_s
    elsif instance_variable_defined?("@#{method_sym}")
      instance_variable_get("@#{method_sym}")
    else
      super
    end
  end

  def visual_hierarchy
    tabs = 0
    hierarchy = ''
    tree_descriptions.each { |d| hierarchy += "#{"\s\s\s" * tabs}|- #{d}\n"; tabs += 1; }
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
