module Bcome::WorkspaceCommands

  def ls
    puts "\n\n" + visual_hierarchy.orange + "\n"
    puts "\tAvailable views: ".cyan.bold + "\n\n"
    @resources.each do |resource|
      puts "\t" + "Identifier: ".cyan + resource.identifier.green
      puts "\t" + "Description: ".cyan + resource.description.green
      puts "\t" + "Type: ".cyan + resource.type.green
      puts "\n"
    end
    new_line
    return
  end

  def cd(identifier)
    if resource = resource_for_identifier(identifier)
      BCOME.set( {
        :current_context => self,
        :context => resource
      })
    else
      puts "#{identifier} not found"
    end
  end

  ## Helpers --

  def resource_identifiers
    @resources.collect(&:identifier)
  end  

  def method_missing(method_sym, *arguments, &block)
    if resource_identifiers.include?(method_sym.to_s)
      return method_sym.to_s
    else  
      super
    end 
  end

  def visual_hierarchy
    tabs = 0
    hierarchy = ""
    tree_descriptions.each {|d| hierarchy += "#{"\s\s\s"*tabs}|- #{d}\n"; tabs += 1;  }
    return hierarchy
  end

  def tree_descriptions
    d = parent ? parent.tree_descriptions + [description] : [description]
    return d.flatten
  end

  def new_line
    puts "\n"
  end

end
