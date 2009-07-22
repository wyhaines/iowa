
# Iowa::Logger is the base class that IOWA loggers all inherit from.
#

module Iowa
	class Logger

		Levels = {:debug => true, :info => true, :warning => true, :error => true, :fatal => true}

		@store = {}

		def self.[](val)
			@store[val]
		end

		def self.[]=(key,val)
			@store[key] = val
		end

		def initialize(*args)
			configure
			open
		end

		def configure
		end

		def open
		end

		def level
			@logger.level
		end

		def level=(lvl)
			l = normalize_level(lvl)
			@level = l
			@logger.level = l
		end

		def normalize_level(lvl)
			l = lvl.to_s.downcase.intern
			l = :debug unless Levels.has_key?(l)
			l
		end

		def debug(msg)
			@logger.debug msg
		end

		def info(msg)
			@logger.info msg
		end

		def warn(msg)
			@logger.warn msg
		end

		def error(msg)
			@logger.error msg
		end

		def fatal(msg)
			@logger.fatal msg
		end

		def close
			@logger.close
		end

		def flush; end

	end
end
