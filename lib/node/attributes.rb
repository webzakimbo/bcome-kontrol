module Bcome::Node::Attributes

  ## -- Attributes --

  def identifier
    @identifier
  end

  def description
    @description
  end  

  def network_driver
    return nil unless network_data
    @network_driver ||= ::Bcome::Driver::Base.create_from_config(network_data)
    return @network_driver
  end

  def ssh_proxy
    return nil unless proxy_data
    @ssh_proxy ||= ::Bcome::Ssh::Proxy.new(proxy_data)
    return @ssh_proxy
  end

  ##-- end Attributes

  def network_data
    get_instance_variable_for(:network)      
  end  

  def proxy_data
    get_instance_variable_for(:proxy)
  end

  def get_instance_variable_for(instance_variable_name)
    # Look on self
    instance_var_name = "@#{instance_variable_name}"

    if instance_variable_defined?(instance_var_name)
      if instance_var = instance_variable_get(instance_var_name)
        return instance_var
      end
    end

    # Look on parent
    if has_parent? && instance_var = parent.instance_variable_get(instance_var_name) 
      return instance_var
    end
    return nil
  end

  def tag_filter_data
    instance_var_name = "@tag_filters"
    if instance_variable_defined?(instance_var_name)
      filters = instance_variable_get(instance_var_name)
    else
      filters = {}
    end
    
    if parent.instance_variable_defined?(instance_var_name)
      parent_filters = parent.instance_variable_get(instance_var_name)
    else
      parent_filters = {}
    end
    
    return filters.merge(parent_filters)
  end

end
