require 'iowa/Logger'
require 'log4r'

module Iowa
	module Loggers
		class Log4rLogger < Iowa::Logger

			def check_errors
				if Iowa.config.has_key? Clogging
					if Iowa.config[Clogging].has_key? Cbasedir
						raise "The logging basedir (#{Iowa.config[Clogging][Cbasedir]}) must be a directory." unless FileTest.directory? Iowa.config[Clogging][Cbasedir]
						raise "The logging basedir #{Iowa.config[Clogging][Cbasedir]}) must be writeable." unless FileTest.writable? Iowa.config[Clogging][Cbasedir]
					end
		
					raise "The minimum logging level (minlevel) must be an integer between 0 to 7, inclusively." if Iowa.config[Clogging].has_key? Cminlevel and (Iowa.config[Clogging][Cminlevel] < 0 or Iowa.config[Clogging][Cminlevel] > 7)
		
					raise "The maximum log file size (maxsize) must be greater than zero." if Iowa.config.has_key? Cmaxsize and Iowa.config[Cmaxsize] <= 0

					raise "The maximum log file age (maxage) must be greater than zero." if Iowa.config.has_key? Cmaxage and Iowa.config[Cmaxage] <= 0
				end
			end

			def configure
				check_errors

				Iowa.config[Clogging][Cbasedir] = '/tmp' unless Iowa.config[Clogging].has_key? Cbasedir
				Iowa.config[Clogging][Cminlevel] = 0 unless Iowa.config[Clogging].has_key? Cminlevel
				Iowa.config[Clogging][Cmaxsize] = 1024 * 1024 unless Iowa.config[Clogging].has_key? Cmaxsize
				Iowa.config[Clogging][Cmaxage] = 86400 unless Iowa.config[Clogging].has_key? Cmaxage
				if Iowa.config[Csocket].has_key? Cpath
					Iowa.config[Clogging][Cfilename] = "#{Iowa.config[Clogging][Cbasedir]}/#{Iowa.config[Csocket][Cbasename]}.log" if Iowa.config[Clogging][Cfilename].nil? or Iowa.config[Clogging][Cfilename] == {}
				else
					Iowa.config[Clogging][Cfilename] = "#{Iowa.config[Clogging][Cbasedir]}/#{Iowa.config[Csocket][Chostname]}_#{Iowa.config[Csocket][Cport]}.log" if Iowa.config[Clogging][Cfilename].nil? or Iowa.config[Clogging][Cfilename] == {}
				end
			end

			def open
				lcfg = Iowa.config[Clogging]
				@logger = ::Log4r::Logger.new ::Iowa::Ciowa_log
				myformat = ::Log4r::PatternFormatter.new :pattern => '[%l] %C @ %d :: %M'
				mybaselog = ::Log4r::RollingFileOutputter.new Cbaselog, :maxsize => lcfg[Cmaxsize], :maxtime => lcfg[Cmaxage], :level => lcfg[Cminlevel], :filename => lcfg[Cfilename], :trunc => false, :formatter => myformat
				@logger.outputters = mybaselog

				@logger.info 'Log4R Logging subsystem initialized.'
			end
		end
	end
end
