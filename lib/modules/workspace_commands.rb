module Bcome::WorkspaceCommands

  def ls
    puts "\n\n" + visual_hierarchy.orange + "\n"
    puts "\tAvailable #{list_key}s: ".cyan.bold + "\n\n"
    @resources.each do |resource|
      list_attributes.each do |key, value| 
        if (resource.respond_to?(value) || resource.instance_variable_defined?("@#{value}"))        
          attribute_value = resource.send(value)
          puts "\t" + "#{key}:\s".cyan + attribute_value.green if attribute_value
        end
      end 
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

  def back
    exit
  end

  ## Helpers --

  def resource_identifiers
    @resources.collect(&:identifier)
  end  

  def method_missing(method_sym, *arguments, &block)
    if resource_identifiers.include?(method_sym.to_s)
      return method_sym.to_s
    elsif instance_variable_defined?("@#{method_sym}")
      return instance_variable_get("@#{method_sym}")
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
