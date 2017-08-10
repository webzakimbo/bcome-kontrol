module Bcome::Parser
  class BreadCrumb
    attr_reader :crumbs

    class << self
      def parse(raw_crumbs)
        parser = new(raw_crumbs)
        return parser.parse!
      end
    end

    def initialize(raw_crumbs)
      @raw_crumbs = raw_crumbs.to_s

      if @raw_crumbs.empty?
        @crumbs = []
      else
        validate!
        parse!
      end
    end

    def parse!
      @crumbs ||= @raw_crumbs.split(':')
    end

    def validate!
      raise Bcome::Exception::InvalidBcomeBreadcrumb unless @raw_crumbs =~ /^([a-z0-9A-Z]+)(:\s*[a-z0-9A-Z]+)*:?$/i
    end
  end
end
