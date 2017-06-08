module Bcome
  class Bootup
    def self.do(params)
      bootup = new(params)
      bootup.do
    end

    attr_reader :breadcrumbs, :argument

    def initialize(params)
      @breadcrumbs = params[:breadcrumbs]
      @argument = params[:argument]
    end

    def do
      crumbs.empty? ? ::Bcome::Workspace.instance.set(context: estate) : traverse(estate)
    end

    def traverse(starting_context)
      starting_context = estate
      crumbs.each_with_index do |crumb, index|
        # Some contexts' resources are loaded dynamically and do not come from the estate config. As we're traversing, we'll need to load
        # them if necessary
        starting_context.load_nodes if starting_context.is_a?(Bcome::Node::Inventory) && !starting_context.nodes_loaded?       

        # Attempt to load our next context resource
        next_context = starting_context.resource_for_identifier(crumb)

        # Our current breadcrumb is not a node, and so we'll attempt to invoke a method call on the previous
        # e.g. given resource:foo, then invoke 'foo' on 'resource'
        unless next_context
          starting_context.invoke(crumb, @argument)
          return
        end
        starting_context = next_context
      end

      # Set our workspace to our last context - we're not invoking a method call and so we're entering a console session
      ::Bcome::Workspace.instance.set(context: starting_context)
    end

    def estate
      @estate ||= ::Bcome::Node::Factory.instance.init_tree
    end

    def parser
      @parser ||= ::Bcome::Parser::BreadCrumb.new(@breadcrumbs)
    end

    def crumbs
      parser.crumbs
    end
  end
end
