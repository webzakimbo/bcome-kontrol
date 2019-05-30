# frozen_string_literal: true

module Bcome::Terraform
  class Parser
    def initialize(namespace)
      @namespace = namespace
    end

    def attributes
      a = {}
      resources.keys.each do |key|
        a[key] = resources[key]['primary']['attributes']
      end
      a
    end

    def resources
      state.resources
    end

    def state
      @state ||= ::Bcome::Terraform::State.new(@namespace)
    end
  end
end
