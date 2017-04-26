module Bcome::Node::Attributes

  ## -- Attributes --

  def identifier
    @identifier
  end

  def description
    @description
  end  

  def type
    @type
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

  def filters
    instance_var_name = "@ec2_filters"
    recurse_hash_data_for_instance_var(instance_var_name, :filters)
  end

  def network_data
    instance_var_name = "@network"
    recurse_hash_data_for_instance_var(instance_var_name, :network)
  end  

  def recurse_hash_data_for_instance_var(instance_var_name, parent_key)
    instance_data = instance_variable_defined?(instance_var_name) ? instance_variable_get(instance_var_name) : {}
    instance_data = {} unless instance_data
    instance_data = parent.send(parent_key).merge(instance_data) if has_parent? 
    return instance_data
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

end
