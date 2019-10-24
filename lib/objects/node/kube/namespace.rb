# frozen_string_literal: true

module Bcome::Node::Kube
  class Namespace < Bcome::Node::Kube::Base
    # CONTAINS PODS

    def get_child_node_command
      "get pods -n #{name}"
    end

    def child_node_klass
      ::Bcome::Kube::Node::Pod
    end

    def get_child_config_from_line(raw_line)
      name, ready, status, restarts, age = raw_line.split("\s")
      { name: name, ready: ready, status: status, reastarts: restarts, age: age }
    end

    def name
      @config[:name]
    end
  end
end
