module Bcome::Node
  class Base

    attr_reader :parent

    include Bcome::Context
    include Bcome::CommonWorkspaceCommands

    def initialize(params)
      view_data = params[:view_data]

      @parent = params[:parent]
      @identifier = view_data["identifier"]
 
      raise ::Bcome::Exception::MissingIdentifierOnView.new unless @identifier
      @resources = []
    end

    def identifier
      @identifier
    end

    def prompt_breadcrumb
      "#{parent.prompt_breadcrumb}> #{identifier}"
    end

    def load_resources
      raise "Should be overidden"
    end

  end
end
