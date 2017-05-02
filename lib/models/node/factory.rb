module Bcome::Node::Factory

  CONFIG_PATH = "config/bcome/estate.yml"
  INVENTORY_KEY = "inventory"
  COLLECTION_KEY = "collection"

 
  class << self
 
    def init_tree
      config = YAML.load_file(CONFIG_PATH).deep_symbolize_keys

      config[:identifier] = config[:identifier] ? config[:identifier] : "bcome"
      config[:description] = config[:description] ? config[:description] : "Your estate"
      config[:type] = config[:type] ? config[:type] : "collection"

      klass = klass_for_view_type[config[:type]]

      estate = klass.new(:view_data => config)
      create_tree(estate, config[:views]) if config[:views] && config[:views].any?

      return estate
    end

    def create_tree(context_node, views)
      views.each do |view|
        raise ::Bcome::Exception::InvalidEstateConfig.new("Invalid view type for (#{view.inspect})") unless is_valid_view_type?(view[:type])
        raise ::Bcome::Exception::InventoriesCannotHaveSubViews.new(view) if has_subviews?(view) && view[:type] == INVENTORY_KEY
        klass = klass_for_view_type[view[:type]]

        view_instance = klass.new({
          :view_data => view,
          :parent => context_node
        })

        if sub_views = view[:views]
          create_tree(view_instance, sub_views)
        end
        context_node.resources << view_instance
      end
    end

    def klass_for_view_type
      {
        COLLECTION_KEY => ::Bcome::Node::Collection,
        INVENTORY_KEY => ::Bcome::Node::Inventory
      }
    end

    def is_valid_view_type?(view_type)
      klass_for_view_type.keys.include?(view_type)
    end

    def has_subviews?(view)
      return view[:views] && !view[:views].empty?
    end

  end
end
