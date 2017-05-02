module Bcome::Node
  class Estate < Bcome::Node::Base

    CONFIG_PATH = "config/bcome/estate.yml"

    class << self
      def init_tree
        config = YAML.load_file(CONFIG_PATH).deep_symbolize_keys

        config[:identifier] = config[:identifier] ? config[:identifier] : "bcome"
        config[:description] = config[:description] ? config[:description] : "Your estate"
        config[:type] = config[:type] ? config[:type] : "collection"

        estate = new(:view_data => config)
        estate.create_tree(config[:views]) if config[:views] && config[:views].any?
        return estate
      end

      def to_s
        "estate"
      end
    end  

    def prompt_breadcrumb
      @identifier
    end

  end
end
