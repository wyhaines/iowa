begin
  load_attempted ||= false
  require 'iowa/Logger'
rescue LoadError => e
  unless load_attempted
    load_attempted = true
    require 'rubygems'
    retry
  else
    raise e
  end
end

module Iowa
  module Loggers
    class BitBucket < Iowa::Logger

      def open
      end

      def debug(msg)
      end

      def info(msg)
      end

      def warn(msg)
      end

      def error(msg)
      end

      def fatal(msg)
      end

    end
  end
end
