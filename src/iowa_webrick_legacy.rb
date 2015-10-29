require 'iowa'
require 'iowa/request/WEBrick'
require 'iowa/webrick/HTTPServer'
require 'rbconfig'

module Iowa
	def Iowa.checkConfiguration
		unless @config.has_key? Csocket
			@config[Csocket][Cport] = 2001
			@config[Csocket][Chostname] = '127.0.0.1'
		end
		@config[Cwebrick] = {} unless @config[Cwebrick].length > 0
		@config[Capplication][Cdaemonize] = false unless @config[Capplication][Cdaemonize].is_a?(String)
		if @config.has_key? Clogging
			if @config[Clogging].has_key? Cbasedir
				raise "The logging basedir (#{@config[Clogging][Cbasedir]}) must be a directory." unless FileTest.directory? @config[Clogging][Cbasedir]
				raise "The logging basedir #{@config[Clogging][Cbasedir]}) must be writeable." unless FileTest.writable? @config[Clogging][Cbasedir]
			end
		
			raise "The minimum logging level (minlevel) must be an integer between 0 to 7, inclusively." if @config[Clogging].has_key? Cminlevel and (@config[Clogging][Cminlevel] < 0 or @config[Clogging][Cminlevel] > 7)

			raise "The maximum log file size (maxsize) must be greater than zero." if @config.has_key? Cmaxsize and @config[Cmaxsize] <= 0

			raise "The maximum log file age (maxage) must be greater than zero." if @config.has_key? Cmaxage and @config[Cmaxage] <= 0
		end

		# Now apply any defaults for optional items which were not specified.

		@config[Clogging] = {} unless @config.has_key? Clogging
		@config[Clogging][Cbasedir] = '/tmp' unless @config[Clogging].has_key? Cbasedir
		@config[Clogging][Cminlevel] = 0 unless @config[Clogging].has_key? Cminlevel
		@config[Clogging][Cmaxsize] = 1024 * 1024 unless @config[Clogging].has_key? Cmaxsize
		@config[Clogging][Cmaxage] = 86400 unless @config[Clogging].has_key? Cmaxage
		if @config[Csocket].has_key? 'path'
			@config[Clogging][Cfilename] = "#{@config[Clogging][Cbasedir]}/#{@config[Csocket]['basename']}.log"
		else
			@config[Clogging][Cfilename] = "#{@config[Clogging][Cbasedir]}/#{@config[Csocket]['hostname']}:#{@config[Csocket]['port']}.log"
		end
		
		@config[Cwebrick]['port'] ||= 2000
		@config[Cwebrick][Cdocroot] ||= '../htdocs'
		@config[Cwebrick]['cgiprefix'] ||= '/cgi-bin'
		@config[Cwebrick]['cgiroot'] ||= '../cgi-bin'
		
		configureExceptionScreens
	end

	def Iowa.handleConnection(request,response)
		start_time = Time.now
		status = 'OK'
		buffer = nil
		iowa_log = Logger[Iowa::Ciowa_log]
		req = Iowa::Request::WEBrick.new(request)
		read_time = Time.now

		buffer = handleRequest(req)	

		if req.status_line and m = /^(\d+)/.match(req.status_line)
			response.status = m[1]
		end
		
		response[ "Date" ] = "#{Time.now.asctime}"
		response[ "Pragma" ] = "no_cache"
		response[ "Connection" ] = "close"
		response[ "Content-type" ] = req.content_type || "text/html"
		response[ "Content-Length" ] = buffer.length
		req.headers_out.each do |k,v| response[ k ] = v end

		response.body = buffer
		
		end_time = Time.now
		referer = req.headers_in['Referer'] != '' ? req.headers_in['Referer'] : request.uri
		iowa_log.info "#{start_time} (#{read_time.to_f - start_time.to_f}/#{end_time.to_f - start_time.to_f}) :: #{req.uri} #{status} #{buffer.length}B"
	end

	def Iowa.run(*args)
		run_check_started(*args)
		mylog = Logger['iowa_log']

		ruby = File.join(::RbConfig::CONFIG['bindir'],
			::RbConfig::CONFIG['ruby_install_name'])
		ruby << ::RbConfig::CONFIG['EXEEXT']

		@config[Cwebrick][Cdocroot] = nil unless @config[Cwebrick].has_key? Cdocroot
		
		mylog.info("Creating WEBrick server on port #{@config[Cwebrick]['port']} with a document root of #{@config[Cwebrick][Cdocroot]}.  The mapfile is at #{Iowa.app.class.Dispatcher.mapfile}, and the Ruby interpreter used for CGI programs is #{ruby}.")
		server = Iowa::HTTPServer.new(
			:Port => @config[Cwebrick]['port'],
			:DocumentRoot => @config[Cwebrick][Cdocroot],
			:MapFile => Iowa.app.class.Dispatcher.mapfile,
			:Logger => mylog,
			:CGIInterpreter => ruby)
		
		if FileTest.exist?(@config[Cwebrick]['cgiroot'])
			file_handler_options = {:HandlerTable => Hash.new(WEBrick::HTTPServlet::CGIHandler)}
			mylog.info("Mounting #{@config[Cwebrick]['cgiroot']} as the cgi-bin directory at #{@config[Cwebrick]['cgiprefix']}.") 
			server.mount(@config[Cwebrick]['cgiprefix'], WEBrick::HTTPServlet::FileHandler, @config[Cwebrick]['cgiroot'], file_handler_options)
		end
				
		trap("INT") {server.shutdown}
		mylog.info("Starting WEBrick...")
		server.start
	end
end
