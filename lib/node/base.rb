module Bcome::Node
  class Base

    attr_reader :parent

    include Bcome::Context
    include Bcome::CommonWorkspaceCommands
    include Bcome::ConsoleColours

    INVENTORY_KEY = "inventory"
    COLLECTION_KEY = "collection"

    def initialize(params)
      view_data = params[:view_data]

      @parent = params[:parent]
      @identifier = view_data["identifier"]
      @description = view_data["description"] 
      raise ::Bcome::Exception::MissingDescriptionOnView.new unless @description
      raise ::Bcome::Exception::MissingIdentifierOnView.new unless @identifier
      @resources = []
    end

    def identifier
      @identifier
    end

    def prompt_breadcrumb
      "#{parent.prompt_breadcrumb}> #{ is_current_context? ? identifier.cyan(:highlight) : identifier}"
    end

    def create_tree(views, top_level = false)
      views.each do |view|
        raise ::Bcome::Exception::InvalidEstateConfig.new unless is_valid_view_type?(view["type"])
        raise ::Bcome::Exception::NoInventoriesAtTopLevel.new if top_level && view["type"] == INVENTORY_KEY
        klass = klass_for_view_type[view["type"]]
        view_instance = klass.new({
          :view_data => view,
          :parent => self
        })

        if sub_views = view["views"]
          view_instance.create_tree(sub_views)
        end

        @resources << view_instance
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

  end
end
