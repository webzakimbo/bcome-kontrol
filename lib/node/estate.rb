module Bcome::Node
  class Bcome::Estate < Bcome::Node::Base

    CONFIG_PATH = "config/bcome/estate.yml"
    ESTATE_IDENTIFIER = "bcome"

    class << self
      def init
        estate = new(
          :view_data => { "identifier" => ESTATE_IDENTIFIER }
        )
        estate.load_resources
        return estate
      end
    end  

    def load_resources
      config = YAML.load_file(CONFIG_PATH)
      
      views = config["views"]
      raise ::Bcome::Exception::NoConfiguredViews.new if (!views && !views.is_a?(Array)) || views.empty?

      top_level = true 
      create_tree(views, top_level) 
    end

    def prompt_breadcrumb
      ::START_PROMPT
    end

  end
end
