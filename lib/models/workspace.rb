class ::Bcome::Workspace
  include ::Singleton

  attr_reader :context

  def initialize
    @context = nil
    @console_set = false
  end

  def set(params)
    init_irb unless console_set?

    @context = params[:context]
    main_context = IRB.conf[:MAIN_CONTEXT]

    @context.irb_workspace = main_context.workspace if main_context
    @context.previous_irb_workspace = params[:current_context] if params[:current_context]
    set_irb_prompt
    spawn_into_console_for_context
    nil
  end

  def console_set!
    @console_set = true
  end

  def console_set?
    @console_set
  end

  def object_is_current_context?(object)
    @context == object
  end

  def spawn_into_console_for_context
    require 'irb/ext/multi-irb'
    IRB.parse_opts_with_ignoring_script
    IRB.irb nil, @context
  end

  def has_context?
    !context.nil?
  end

  def irb_prompt
    @context ? @context.prompt_breadcrumb : default_prompt
  end

  def default_prompt
    'bcome'
  end

  protected

  def init_irb
    IRB.setup nil
    IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context
    console_set!
  end

  def set_irb_prompt
    IRB.conf[:PROMPT][:CUSTOM] = {
      PROMPT_N: "\e[1m:\e[m ",
      PROMPT_I: "\e[1m#{irb_prompt} >\e[m ",
      PROMPT_C: "\e[1m#{irb_prompt} >\e[m ",
      RETURN: "%s \n"
    }
    IRB.conf[:PROMPT_MODE] = :CUSTOM
  end
end
