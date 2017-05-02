module Bcome::Node
  class Estate < Bcome::Node::Base

    CONFIG_PATH = "config/bcome/estate.yml"

    class << self
      def init_tree
        estate = new(
          :view_data => { 
            :identifier => "bcome",
            :description => "Your estate",
            :type => "collection"
          }
        )
        estate.load_resources
        return estate
      end

      def to_s
        "estate"
      end
    end  

    def load_resources
      config = YAML.load_file(CONFIG_PATH).deep_symbolize_keys
 
      views = config[:views]
      raise ::Bcome::Exception::NoConfiguredViews.new if !views || !views.is_a?(Array) || views.empty?

      create_tree(views)
    end

    def prompt_breadcrumb
      ::Bcome::Workspace.instance.default_prompt
    end

  end
end
