require 'iowa/Logger'
require 'logger'

module Iowa
	module Loggers
		class Logger < Iowa::Logger
			Intervals = {:daily => true, :weekly => true, :monthly => true}

			def open
				logfile = File.join(Iowa.config[Clogging][Cbasedir], (Iowa.config[Clogging][Cfilename] || 'iowa.log'))

				logargs = []
				if Intervals.has_key?(Iowa.config[Clogging][Cmaxage].to_s.downcase.intern)
					logargs << Iowa.config[Clogging][Cmaxage].to_s.downcase
				else
					maxfiles = Iowa.config[Clogging].has_key?(Cmaxfiles) ? Iowa.config[Clogging][Cmaxfiles] : 10
					logargs << maxfiles
					logargs << Iowa.config[Clogging][Cmaxsize]
				end
				@logger = Logger.new(logfile,*logargs)
			end

		end
	end
end
