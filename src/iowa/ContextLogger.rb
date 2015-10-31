require 'iowa/Logger'

module Iowa
  class ContextLogger < Logger
    def initialize(*args)
      @log_context = []
      super
    end

    def context(label)
      @log_context.push label
      yield
      @log.pop
    end
  end
end
