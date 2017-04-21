class ::Bcome::WorkspaceManager  

  attr_reader :context

  def set(params) # { :context => context, :current_context => current_context, :spawn => spawn }
    @context = params[:context]
    main_context = IRB.conf[:MAIN_CONTEXT]

    @context.irb_workspace = main_context.workspace if main_context
    @context.previous_irb_workspace = params[:current_context] if params[:current_context]

    # Spawn is initiated when a user wants to shift workspace context.
    # We don't spawn whilst setting up the hierarchy for quick contexts 
    spawn_for_context(@context) if params[:spawn]
    return
  end

  def spawn_for_context(context)
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
