module Bcome
  class Bootup

    class << self
      def do(params)
        bootup = new(params)
        bootup.do    
      end
    end

    def initialize(params)
      @raw_breadcrumbs = params[:raw_breadcrumbs]
    end

    def do
      if crumbs.empty?
        ::BCOME.set({ context: estate })
      else
        starting_context = estate
        crumbs.each do |crumb|    
          next_context = starting_context.resource_for_identifier(crumb)
          unless next_context
            # Execute the final crumb as a method call on our penultimate context e.g. foo:bar:ssh
            if starting_context.respond_to?(crumb)
              starting_context.send(crumb)
              return
            else
              # Final crumb is neither a node level context nor an executable method on the penultimate node level context
              raise ::Bcome::Exception::InvalidBreadcrumb.new("Method '#{crumb}' is not available on bcome node of type #{starting_context.class}, at namespace #{starting_context.namespace}")
              return
            end
          end
          starting_context = next_context
        end
        ::BCOME.set(context: starting_context)
      end 
    end

    def estate
      @estate ||= ::Bcome::Estate.init_tree
    end

    def parser
      @parser ||= ::Bcome::BreadcrumbParser.new(@raw_breadcrumbs)
    end

    def crumbs
      parser.crumbs
    end 

  end
end
