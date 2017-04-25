class ::Bcome::WorkspaceManager  

  attr_reader :context

  ### TODO
  ##  bcome run "whatever"
  ##  bcome wbz:prod
  ##  bcome wbz:prod:run "whatever"

  def init_workspace(context_crumbs = [])
    starting_context = ::Bcome::Estate.init_tree

    if context_crumbs.empty?
      # Direct console access at the Estate node level
      BCOME.set({ :context => starting_context })
    else
      context_crumbs.each do |crumb|
        next_context = starting_context.resource_for_identifier(crumb)
        unless next_context
          # Execute the final crumb as a method call on our penultimate context e.g. foo:bar:ssh
          if starting_context.respond_to?(crumb)
            starting_context.send(crumb)
            return
          else
            # Final crumb is neither a node level context nor an executable method on the penultimate node level context
            puts "No method #{crumb} available for #{starting_context.class} at namespace #{starting_context.namespace}"
            return
          end
        end
        starting_context = next_context 
      end
      # Our final crumb relates to context, and so enter the console at this node level
      BCOME.set({ :context => starting_context })
    end  
  end

  def set(params)
    @context = params[:context]
    main_context = IRB.conf[:MAIN_CONTEXT]

    @context.irb_workspace = main_context.workspace if main_context
    @context.previous_irb_workspace = params[:current_context] if params[:current_context]

    spawn_into_console_for_context(@context) 
    return
  end

  def invoke_on_current_context(method)
    @context.send(method)
  end

  def object_is_current_context?(object)
    @context == object
  end

  def spawn_into_console_for_context(context)
    require 'irb/ext/multi-irb'
    IRB.parse_opts_with_ignoring_script
    IRB.irb nil, @context
  end

  def has_context?
    !self.context.nil?
  end

  def irb_prompt
    @context ?  @context.prompt_breadcrumb : ::START_PROMPT
  end

  def is_sudo?
    @context.is_sudo?
  end

end
