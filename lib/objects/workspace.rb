# frozen_string_literal: true

class ::Bcome::Workspace
  include ::Singleton

  attr_reader :context
  attr_reader :estate

  def initialize
    @context = nil
    @console_set = false
    @estate = nil
  end

  def set(params)
    init_irb unless console_set?

    @context = params[:context]
    @context.load_nodes if @context.inventory? && !@context.nodes_loaded?

    main_context = IRB.conf[:MAIN_CONTEXT]

    @context.irb_workspace = main_context.workspace if main_context
    @context.previous_irb_workspace = params[:current_context] if params[:current_context]

    show_welcome if params[:show_welcome]

    spawn_into_console_for_context
    nil
  end

  def show_welcome
    puts "\n\n"
    puts "Welcome to bcome v#{::Bcome::Version.release}".bc_yellow
    puts "\nType\s" + "menu".underline + "\sfor a command list, or\s" + "registry".underline + "\s to view your custom tasks."
    puts "\n\n"
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
    ::IRB.start_session(self, @context)
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
end
