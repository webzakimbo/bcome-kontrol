module Bcome
  class Bootup

    class << self
      def do(params, spawn_into_console = true)
        begin
          bootup = new(params, spawn_into_console)
          context = bootup.do
          return context
        rescue Bcome::Exception::Base => e
          puts e.pretty_display
        rescue Excon::Error::Socket => e
          puts "\nNo network access - please check your connection and try again\n".red
        end
      end

      def orchestrate(breadcrumbs = nil, spawn_into_console = false)
        spawn_into_console = false
        context = ::Bcome::Bootup.do( { breadcrumbs: breadcrumbs }, spawn_into_console)
        return context
      end
    end

    attr_reader :breadcrumbs, :argument

    def initialize(params, spawn_into_console = false)
      @breadcrumbs = params[:breadcrumbs]
      @arguments = params[:arguments]
      @spawn_into_console = spawn_into_console
    end

    def do
      crumbs.empty? ? init_context(estate) : traverse(estate)
    end

   def init_context(context)
     if @spawn_into_console
       ::Bcome::Workspace.instance.set( context: context )
     else
       return context
     end 
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
          starting_context.invoke(crumb, @arguments)
          return
        end
        starting_context = next_context
      end

      # Set our workspace to our last context - we're not invoking a method call and so we're entering a console session
      init_context(starting_context) 
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
