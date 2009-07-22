require 'iowa/Logger'
require 'logger'

module Iowa
	module Loggers
		class RubyLogger < Iowa::Logger
			Intervals = {:daily => true, :weekly => true, :monthly => true}

			def open
				logfile = File.join(Iowa.config[Clogger][Cbasedir], Iowa.config[Clogger][Cfilename])

				logargs = []
				if Intervals.has_key?(Iowa.config[Clogger][Cmaxage].to_s.downcase.intern)
					logargs << Iowa.config[Clogger][Cmaxage].to_s.downcase
				else
					maxfiles = Iowa.config[Clogger].has_key?(Cmaxfiles) ? Iowa.config[Clogger][Cmaxfiles] : 10
					logargs << maxfiles
					logargs << Iowa.config[Clogger][Cmaxsize] || 1024 * 1024
				end
				@logger = ::Logger.new(logfile,*logargs)
			end

		end
	end
end
