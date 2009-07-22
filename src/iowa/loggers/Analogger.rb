begin
	load_attempted ||= false
	require 'iowa/Logger'
	require 'swiftcore/Analogger/Client'
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
		class Analogger < Iowa::Logger

			def configure
				conf = Iowa.config[Clogger]
				conf[Cservice] ||= 'default'
				conf[Chost] ||= '127.0.0.1'
				conf[Cport] ||= 6766
				conf[Ckey] ||= nil
			end

			def open
				conf = Iowa.config[Clogger]
				@logger = ::Swiftcore::Analogger::Client.new(conf[Cservice],conf[Chost],conf[Cport],conf[Ckey])
			end

			def debug(msg)
				@logger.log(Cdebug,msg)
			end

			def info(msg)
				@logger.log(Cinfo,msg)
			end

			def warn(msg)
				@logger.log(Cwarn,msg)
			end

			def error(msg)
				@logger.log(Cerror,msg)
			end

			def fatal(msg)
				@logger.log(Cfatal,msg)
			end

		end
	end
end
