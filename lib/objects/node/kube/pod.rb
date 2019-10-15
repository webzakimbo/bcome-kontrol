# frozen_string_literal: true

module Bcome::Node::Kube
  class Pod < Bcome::Node::Kube::Base
    # CONTAINS CONTAINERS

    def get_child_node_command
      "get pods #{name} -n #{parent.name} -o jsonpath=‘{.spec.containers[*].name}’"
    end

    def child_node_klass
      ::Bcome::Kube::Node::Container
    end

    def name
      @config[:name]
    end

    def get_child_config_from_line(raw_line)
      name = raw_line.split("\s")
      { name: name }
    end
  end
end
