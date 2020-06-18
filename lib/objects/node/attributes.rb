# frozen_string_literal: true

module Bcome::Node::Attributes
  ## -- Attributes --

  def identifier
    @identifier
  end

  def ssh_driver
    @ssh_driver ||= ::Bcome::Ssh::Driver.new(ssh_data, self)
  end

  def ssh_data
    recurse_hash_data_for_instance_key(:ssh_settings, :ssh_data)
  end

  def network_data
    recurse_hash_data_for_instance_key(:network, :network_data)
  end

  # From 2.0.0 onwards, filters can be loaded from the network block only. The older key, 'ec2_filters'
  #  is retained at this level for backwards compatibility.
  def filters
    recurse_hash_data_for_instance_key(:ec2_filters, :filters)
  end

  def network_driver
    return nil if !network_data || (network_data.is_a?(Hash) && network_data.empty?)

    @network_driver ||= ::Bcome::Driver::Bucket.instance.driver_for_network_data(network_data, self)
    @network_driver
  end

  def recurse_hash_data_for_instance_key(instance_key, parent_key)
    instance_data = respond_to?(instance_key) ? send(instance_key) : {}
    instance_data ||= {}
    instance_data = parent.send(parent_key).deep_merge(instance_data) if has_parent?
    instance_data
  end
end
