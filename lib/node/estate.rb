module Bcome::Node
  class Bcome::Estate < Bcome::Node::Base

    CONFIG_PATH="config/bcome/estate.yml"

    ESTATE_IDENTIFIER="bcome"

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

    def create_tree(views, top_level = false)
      views.each do |view|
        raise ::Bcome::Exception::InvalidEstateConfig.new unless is_valid_view_type?(view["type"])
        klass = klass_for_view_type[view["type"]]
        @resources << klass.new({
          :view_data => view,
          :parent => self
        })
      end     
    end

    def klass_for_view_type
      {
        "collection" => ::Bcome::Node::Collection,
        "inventory" => ::Bcome::Node::Inventory
      } 
    end

    def is_valid_view_type?(view_type)
      klass_for_view_type.keys.include?(view_type)
    end

  end
end
