module Bcome
  class Bootup

    def self.do(params)
      bootup = new(params)
      bootup.do    
    end

    def initialize(params)
      @breadcrumbs = params[:breadcrumbs]
      @command = params[:command]
    end

    def do
      crumbs.empty? ? ::BCOME.set({ context: estate }) : traverse(estate)
    end

    def traverse(starting_context)
      starting_context = estate
      crumbs.each do |crumb|
        starting_context.load_dynamic_nodes unless starting_context.nodes_loaded?
        next_context = starting_context.resource_for_identifier(crumb)
        unless next_context
          starting_context.invoke(crumb, @command)
          return
        end
        starting_context = next_context
      end
      ::BCOME.set(context: starting_context)
    end

    def estate
      @estate ||= ::Bcome::Estate.init_tree
    end

    def parser
      @parser ||= ::Bcome::Parser::BreadCrumb.new(@breadcrumbs)
    end

    def crumbs
      parser.crumbs
    end 

  end
end
