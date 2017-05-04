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

  def ssh_data
    instance_var_name = '@ssh_settings'
    recurse_hash_data_for_instance_var(instance_var_name, :ssh_data)
  end

  def network_driver
    data = network_data
    return nil unless data
    @network_driver ||= ::Bcome::Driver::Base.create_from_config(data)
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
    instance_data = {} unless instance_data
    instance_data = parent.send(parent_key).merge(instance_data) if has_parent?
    instance_data
  end
end
