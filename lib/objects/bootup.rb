module Bcome
  class Bootup
    def self.set_and_do(params, spawn_into_console = true)
      instance.set(params, spawn_into_console)
      instance.do
    rescue Bcome::Exception::Base => e
      puts e.pretty_display
    rescue Excon::Error::Socket => e
      puts "\nNo network access - please check your connection and try again\n".red
    end

    def self.traverse(breadcrumbs = nil, _spawn_into_console = false)
      spawn_into_console = false
      ::Bcome::Bootup.set_and_do({ breadcrumbs: breadcrumbs }, spawn_into_console)
    end

    include Singleton

    attr_reader :breadcrumbs, :arguments

    def set(params, spawn_into_console = false)
      @breadcrumbs = params[:breadcrumbs]
      @arguments = params[:arguments]
      @spawn_into_console = spawn_into_console
    end

    def do
      context = crumbs.empty? ? init_context(estate) : traverse(estate)
      context
    end

    def init_context(context)
      if @spawn_into_console
        ::Bcome::Workspace.instance.set(context: context)
      else
        context
      end
    end

    def traverse(_starting_context)
      starting_context = estate
      crumbs.each_with_index do |crumb, _index|
        # Some contexts' resources are loaded dynamically and do not come from the estate config. As we're traversing, we'll need to load
        # them if necessary
        starting_context.load_nodes if starting_context.inventory? && !starting_context.nodes_loaded?

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
      ::Bcome::Parser::BreadCrumb.new(@breadcrumbs)
    end

    def crumbs
      parser.crumbs
    end

    private

    def teardown!
      @estate = nil
    end
  end
end
