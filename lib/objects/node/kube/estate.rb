# frozen_string_literal: true

module Bcome::Node::Kube
  class Estate < Bcome::Node::Kube::Base
    # CONTAINS NAMESPACES
    def get_child_node_command
      'get namespaces'
    end

    def child_node_klass
      ::Bcome::Kube::Node::Namespace
    end

    def get_child_config_from_line(raw_line)
      name, active, age = raw_line.split("\s")
      { name: name, active: active, age: age }
    end
  end
end
