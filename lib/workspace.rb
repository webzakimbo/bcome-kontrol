class ::Bcome::Workspace  

  attr_reader :context

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
