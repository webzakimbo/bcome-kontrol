module Bcome::WorkspaceCommands

  def ls
    puts "\n\n" + visual_hierarchy.orange + "\n"
    puts "\tAvailable #{list_key}s: ".cyan + "\n\n"

    @resources.sort_by(&:identifier).each do |resource|
      puts resource.pretty_description
      puts "\n"
    end
    new_line
    nil
  end

  def cd(identifier)
    if resource = resources.for_identifier(identifier)
      ::Bcome::Workspace.instance.set(current_context: self, context: resource)
    else
      puts "#{identifier} not found"
    end
  end

  def pretty_description
    desc = ''
    list_attributes.each do |key, value|
      next unless respond_to?(value) || instance_variable_defined?("@#{value}")
      attribute_value = send(value)
      next unless attribute_value
      desc += "\t#{key}".cyan
      desc += "\s" * (12 - key.length)
      attribute_value = value == :identifier ? attribute_value.underline : attribute_value
      desc += attribute_value.green + "\n"
    end
    desc
  end

  def back
    exit
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
