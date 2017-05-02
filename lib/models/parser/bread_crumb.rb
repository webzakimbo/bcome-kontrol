module Bcome::Parser
  class BreadCrumb

    attr_reader :crumbs

    def initialize(raw_crumbs)
      @raw_crumbs = raw_crumbs
      if @raw_crumbs.nil?
        @crumbs = []
      else 
        validate!
        parse!
      end
    end

    def parse!
      @crumbs ||= @raw_crumbs.split(":")
    end

    def validate!
      raise ::Bcome::Exception::InvalidBcomeBreadcrumb.new unless @raw_crumbs =~ /^([a-z0-9A-Z]+)(:\s*[a-z0-9A-Z]+)*$/i
    end

  end
end
