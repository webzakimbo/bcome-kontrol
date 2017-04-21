module Bcome::CommonWorkspaceCommands

  def ls
    new_line
    @resources.each do |resource|
      puts "\t#{resource.identifier}"
    end
    new_line
    return
  end

  def cd(identifier)
    resource = @resources.select{|r| r.identifier == identifier}.first
    if resource

      BCOME.set( {
        :current_context => self,
        :context => resource,
        :spawn => true
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
