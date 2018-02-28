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

  def ssh_driver
    @ssh_driver ||= ::Bcome::Ssh::Driver.new(ssh_data, self)
  end

  def ssh_data
    instance_var_name = '@ssh_settings'
    recurse_hash_data_for_instance_var(instance_var_name, :ssh_data)
  end

  def network_driver
    return nil if !network_data || (network_data.is_a?(Hash) && network_data.empty?)
    @network_driver ||= ::Bcome::Driver::Bucket.instance.driver_for_network_data(network_data)
    @network_driver
  end

  def filters
    instance_var_name = '@ec2_filters'
    recurse_hash_data_for_instance_var(instance_var_name, :filters)
  end

  def network_data
    instance_var_name = '@network'
    recurse_hash_data_for_instance_var(instance_var_name, :network_data)
  end

  def recurse_hash_data_for_instance_var(instance_var_name, parent_key)
    instance_data = instance_variable_defined?(instance_var_name) ? instance_variable_get(instance_var_name) : {}
    instance_data ||= {}
    instance_data = parent.send(parent_key).deep_merge(instance_data) if has_parent?
    instance_data
  end
end
