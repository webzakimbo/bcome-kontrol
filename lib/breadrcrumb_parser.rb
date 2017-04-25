module Bcome
  class BreadcrumbParser

    attr_reader :crumbs

    def initialize(raw_crumbs)
      @raw_crumbs = raw_crumbs
      @crumbs = [] if @raw_crumbs.nil?
      validate!
      parse!
    end

    def parse!
      @crumbs ||= @raw_crumbs.split(":")
    end

    def validate!
      raise ::Bcome::Exception::InvalidBcomeBreadcrumb.new unless @raw_crumbs =~ /^([a-z0-9A-Z]+)(:\s*[a-z0-9A-Z]+)*$/i
    end

  end
end
