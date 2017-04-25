module Bcome::CommonWorkspaceCommands

  def ls
    new_line
    puts view_title("\s#{@description}\n")
    @resources.each do |resource|
      puts "\t#{resource.identifier}"
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

  def new_line
    puts "\n"
  end

end
