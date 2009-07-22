require 'iowa/Logger'

module Iowa
	module Loggers
		class AsyncLogger < Iowa::Logger
			def initialize
				@queue = []
				@periodic_flush = Thread.start { flush_periodically }
				super
			end

			def debug(msg)
				@queue << [:debug,msg]
			end

			def info(msg)
				@queue << [:info,msg]
			end

			def warn(msg)
				@queue << [:warn,msg]
			end

			def error(msg)
				@queue << [:error,msg]
			end

			def fatal(msg)
				@queue << [:fatal,msg]
			end

			def close
				@periodic_flush.stop
				flush
				super
			end

			def flush_periodically
				loop do
					sleep 1
					flush
				end
			end

			def flush
				while msg = @queue.shift
					@logger.__send__(msg.first,msg.last)
					msg = nil
				end
			end

		end
	end
end
