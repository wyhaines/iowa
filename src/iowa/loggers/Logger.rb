require 'iowa/Logger'
require 'logger'

module Iowa
  module Loggers
    class Logger < Iowa::Logger
      Intervals = {:daily => true, :weekly => true, :monthly => true}

      def open
        log_root = Iowa.config[Clogger].has_key?(Cbasedir) ?
          ( Iowa.config[Clogger][Cbasedir].index('/') == 0 ?
            File.expand_path( Iowa.config[Clogger][Cbasedir] ) :
            File.expand_path( File.join( Iowa::Application.iowa_root, Iowa.config[Clogger][Cbasedir] ) ) ) :
          Iowa::Application.log_root 
        logfile = File.join(log_root, (Iowa.config[Clogger][Cfilename] || 'iowa.log'))
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
