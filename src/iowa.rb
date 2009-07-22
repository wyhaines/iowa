begin
  require 'rubygems'
rescue Exception
end

require 'yaml'
#require 'log4r'
#include Log4r

require 'iowa/Constants'
require 'iowa/Config'
require 'iowa/Util'
require 'iowa/String'
require 'iowa/TemplateParser'
require 'iowa/Hash'
require 'iowa/Association'
require 'iowa/Context'
require 'iowa/Element'
require 'iowa/Tag'
require 'iowa/DynamicElements'
require 'iowa/Form'
require 'iowa/Component'
require 'iowa/DetachedComponent'
require 'iowa/ComponentProxy'
require 'iowa/BindingsParser'
require 'iowa/KeyValueCoding'
require 'iowa/Session'
require 'iowa/Application'
require 'iowa/Request'
require 'iowa/Response'
require 'iowa/Email'
require 'iowa/PrettyException'
#require 'iowa/request/Apache'
#require 'iowa/request/FCGI'
#require 'iowa/request/WEBrick'
#require 'iowa/request/Mongrel'
require 'iowa/request/ENV'

require 'socket'
require 'resolv'
require 'optparse'
require 'fileutils'

module Iowa
	@app = nil

	def self.started?
		@started ||= nil
	end

	def self.started=(val)
		@started = val
	end

	# Forks the process.  The parent outputs the PID of the child (so that
	# an external invocation process can capture this information) and then
	# exits.  The child sets inself as it's session leader and returns.

	def self.startDaemon(configuration_file,daemonize = nil)
		self.started = true
		Iowa::Application.applicationClass.Config = configuration_file if configuration_file and FileTest.exist?(configuration_file)
		app

		mylog = Logger[Ciowa_log]
		
		daemonize = @config[Capplication][Cdaemonize] if daemonize.nil? and @config[Capplication].has_key?(Cdaemonize)
		daemonize = true if daemonize.nil?

		if daemonize
			begin
				if (child_pid = fork)
					puts "PID #{child_pid}"
					exit!
				end
				Process.setsid

				mylog.info "Application started in #{Iowa.runmode} mode; process forked and daemonized as PID #{Process.pid}."
			rescue Exception
				mylog.info "Platform (#{RUBY_PLATFORM}) does not appear to support fork/setsid; skipping"
			end
		else
			mylog.info "Application started; process not forked."
		end
	end

	def self.configureExceptionScreens
		@exception_screens = []
		@exception_hosts = []
		if @config.has_key?(Cexceptions)
			if @config[Cexceptions].has_key?(Cscreens)
				@config[Cexceptions][Cscreens].each do |item|
					new_item = {}
					next unless item.is_a?(::Hash)
					item.each do |k,v|
						k.sub!(/^\s+/,'')
						v.sub!(/^\s+/,'')
						c,m = v.split('.',2)
						dd = Iowa::DispatchDestination.new(c,m)
						if m = /^\/(.*)\//.match(k)
							new_item[Regexp.new(m[1]),true] = dd
						else
							new_item[k] = dd
						end
					end
					@exception_screens.push(new_item)
				end
			end
			if @config[Cexceptions].has_key?(Chosts)
				@config[Cexceptions][Chosts].each do |item|
					new_item = {}
					next unless item.is_a?(::Hash)
					item.each do |k,v|
						k.sub!(/^\s+/,'')
						if v.is_a?(Array)
							list = []
							v.each {|x| list.push(Regexp.new(x.sub(/^\s+/,''),true))}
							new_item[k] = list
						end
					end
					@exception_hosts.push(new_item)
				end
			end
		end
	end

	# configuration, and set the defaults for information that was
	# omitted. Exceptions will be raised if socket information is
	# missing, or if either socket or logging information seems to
	# have errors.

	def self.checkConfiguration
		cc_setup
		cc_socket
		cc_logging
		cc_misc

		configureExceptionScreens
	end

	private
	def self.cc_setup
		# Make sure socket info was provided
		@config[Csocket][Cport] = 2001 if (!@config[Csocket].has_key?(Cport) and !@config[Csocket].has_key?(Cpath))
		@config[Csocket][Chostname] = '127.0.0.1' if (!@config[Csocket].has_key?(Chostname) and !@config[Csocket].has_key?(Cpath))
	end

	def self.cc_misc
		@config[Capplication][Cdaemonize] = false unless @config[Capplication].has_key?(Cdaemonize)
		@config[Capplication][Cdoc_root] = File.expand_path(@config[Capplication][Cdoc_root]) if @config[Capplication].has_key?(Cdoc_root)
		@config[Capplication][Ccgi_root] = File.expand_path(@config[Capplication][Ccgi_root]) if @config[Capplication].has_key?(Ccgi_root)
	end

	def self.cc_logging
		unless @config.has_key?(Clogger)
			if @config.has_key?(Clogging)
				@config[Clogger] = @config[Clogging]
				@config[Clogger][Cclass] = 'Log4rLogger'
			else
				@config[Clogger][Cclass] = 'RubyLogger'
			end
		end
		@config[Clogger][Cbasedir] = @config[Capplication][Clog_root] || '.' unless @config[Clogger].has_key?(Cbasedir)
		@config[Clogger][Cfilename] = 'iowa_log' unless @config[Clogger].has_key?(Cfilename)
		@config[Clogger][Cmaxage] = :daily unless @config[Clogger].has_key?(Cmaxage)
	end

	def self.cc_socket_errors
		raise "Please define only one of a TCP or a Unix domain socket in the configuration file." if @config[Csocket].has_key?(Cpath) and @config[Csocket].has_key?(Cport)
		raise "The socket hostname contains illegal characters." unless @config[Csocket].has_key?(Chostname) and @config[Csocket][Chostname] =~ /^[a-zA-Z0-9\.\-]*$/
	end

	def self.cc_socket_resolveable
		if @config[Csocket].has_key?(Chostname) and @config[Csocket][Chostname] !~ /^\s*\d+\.\d+\.\d+\.\d+\s*$/
			begin
				@config[Csocket][Chostname] = Resolv::getaddress(@config[Csocket][Chostname])
			rescue Resolv::ResolvError
				raise "The socket hostname must be resolveable to an IP address."
			end
		end
	end

	def self.cc_socket_valid_path
		if @config[Csocket].has_key? Cpath
			begin
				File.unlink @config[Csocket][Cpath] if FileTest.exist? @config[Csocket][Cpath]
				sf = File.open(@config[Csocket][Cpath],'w')
				@config[Csocket][Cbasename] = File.basename(@config[Csocket][Cpath])
				sf.close
				File.unlink @config[Csocket][Cpath]
			rescue Exception => exception
				puts "The path for a Unix socket must be writeable."
				raise
			end
		end
	end

	def self.cc_socket
		cc_socket_errors
		cc_socket_resolveable
		cc_socket_valid_path
	end
	public
	# Initialize logging mechanisms

	def self.startLogging
		lcfg = @config[Clogging]
		mylog = Logger.new Ciowa_log
		myformat = PatternFormatter.new :pattern => '[%l] %C @ %d :: %M'
		mybaselog = RollingFileOutputter.new Cbaselog, :maxsize => lcfg[Cmaxsize], :maxtime => lcfg[Cmaxage], :level => lcfg[Cminlevel], :filename => lcfg[Cfilename], :trunc => false, :formatter => myformat
		mylog.outputters = mybaselog

		mylog.info 'Logging subsystem initialized.'
	end

	def self.maybe_kind_of(obj,classname)
		r = false
		obj.class.ancestors.each {|a| r ||= a.to_s == classname}
		r
	end
	
	# Check the exception against the list of exception screens, if any.  Return as
	# soon as a match is found.

	def self.checkScreen(exception)
		klass = exception.class.to_s
		@exception_screens.each do |item|
			item.each do |k,v|
				if k.is_a?(Regexp)
					if k.match(klass)
						return v
					end
				elsif maybe_kind_of(exception,k)
					return v
				end
			end
		end
		nil
	end

	def self.internal_host?(request)
		addr = false
		browser = false
		@exception_hosts.each do |host|
			if host.has_key?(Caddresses)
				host[Caddresses].each do |a|
					if a.match(request.remote_host)
						addr = true
						break
					end
				end
			elsif host.has_key?(Cips)
				host[Cips].each do |i|
					if i.match(request.remote_addr)
						addr = true
						break
					end
				end
			else
				addr = true
			end
			if host.has_key?(Cbrowsers)
				host[Cbrowsers].each do |b|
					if b.match(request.headers_in[CUserAgent])
						browser = true
						break
					end
				end
			else
				browser = true
			end
		end
		(addr and browser)
	end

	def self.handleRequest(request)
		mylog = Logger[Ciowa_log]
		deployed_screen = false
		dispatch_destination = nil
		response = Iowa::Response.new(200)
		original_exception = nil
		context = nil
		loop do
			response.content_type = Ctext_html
			exception = nil
			exception = catch(:session_error) do
				begin
					context = Iowa::Context.new(request, response)
					context.prior_exception = original_exception if original_exception
					app.handleRequest(context,dispatch_destination)
				rescue Exception => exception
				end
			end
			if exception.to_s != C_empty and exception.kind_of?(Exception)
				mylog = Logger[Ciowa_log]
				mylog.warn "Execution Error: #{exception} :: " + exception.backtrace.join(".....").to_s unless original_exception
				if internal_host?(request)
					mylog.info "Showing PrettyException"
					response << Iowa::PrettyException.new(exception).to_s
				else
					if deployed_screen == false and dispatch_destination = checkScreen(exception)
						dd = dispatch_destination.method ? "#{dispatch_destination.component}.#{dispatch_destination.method}" :
							dispatch_destination.component
						mylog.info "Deploying exception screen #{dd}"
						response.status = Iowa::Response::InternalServerError
						original_exception = exception
						deployed_screen = true
						retry
					else
						response.status = Iowa::Response::InternalServerError unless response.status >= 400
						mylog.info "Showing ugly exception"
						exception = original_exception if original_exception
						response << "<p> An unhandled error has occured.  Please inform your system or site's administrator of the error.</p>" if response.status == Iowa::Response::InternalServerError
						response << "<p>#{exception.to_s.gsub("<","&lt;")}<br/>"
						response << "</p>"
						status = 'EOUT'
					end
				end
			end
			break
		end

		# Unless the app forbids it or this is a page that went into the page cache,
		# at this point we will write a cache of the generated page to the filesystem.
		# This will allow pages that only need to be generated occasionally to be
		# served as static content most of the time.  Whether this is turned on or not
		# is controlled by an application level config option, docroot_caching.  It is
		# turned off by default.
		if context[:skip_pagecache] and context[:allow_docroot_caching]
			if Iowa.config[Capplication][Cdocroot_caching]
				if context.request.params['QUERY_STRING'].to_s != ''
					path = "#{File.expand_path(File.join(Iowa.config[Capplication][Cdoc_root],context.request.uri))}__#{context.request.params['QUERY_STRING']}"
				else
					path = "#{File.expand_path(File.join(Iowa.config[Capplication][Cdoc_root],context.request.uri))}"
				end
				# Make sure that the path is inside the docroot!
				if (path.index(Iowa.config[Capplication][Cdoc_root]) == 0)
					begin
						mylog.info "Writing cache entry: #{path}"
						FileUtils.mkdir_p(File.dirname(path))
						File.open(path,'w+') {|fh| fh.write response.body}
					rescue Exception => e
						# Well, that's too bad.  Report the error and go on.
						mylog.error "Error while writing filesystem cached page: #{e}"
					end
				end
			end
		end
		if context.session
			context.session.context = nil
			context.session = nil
		end
		
		response
	end

	# Handle the communications coming in on the monitored socket,
	# create a context object from the data received, and then pass
	# the context information into the Application object for final
	# handling.  Exception handling is simply via capturing the Exception
	# and outputting a stack backtrace (this could be improved).

	def self.handleConnection(socket)
		begin
			Thread.current.priority = 2
			start_time = Time.now
			mylog = Logger[Ciowa_log]
			message = ''
			while (recv = socket.recv(8192)) != C_empty
				message << recv
			end
			socket.shutdown(0)
			read_time = Time.now
			status = [COK]
		rescue Exception => exception
			mylog.error "Failure While Reading Inbound Data: #{exception}"
			# TODO: When this happens, we need to either create a Request and return a useful response, or close the socket.
			status = [CEIN, "Failure While Reading Inbound Data: #{exception}"]
		end

		begin
			request = Marshal.load(message)
			unless request.headers and request.headers.length > 0
				request.headers = request.headers_in if request.headers_in.respond_to?(:length) and request.headers_in.length > 0
			end
			# Backward compatible yuckiness.
			#request.content_type = nil
			#request.status_line = nil
			#request.headers_out = {}
		rescue Exception => exception
			mylog.error "Inbound Data Corruption: #{exception}"
			status = [CEIN,"Inbound Data Corruption: #{exception}"]
		end

		unless status[0] == CEIN
			response = handleRequest(request)
			# Backward compatible yuckiness, continued.
			response.status_line = request.status_line if request.status_line
			response.content_type = request.content_type if request.content_type
			status[0] = response.status_line
			if request.headers_out.respond_to?(:length) and request.headers_out.length > 0
				request.headers_out.each {|k,v| response.headers.set(k,v)}
			end

			begin
				message = Marshal.dump(response)
				socket.write(message)
				socket.flush
				socket.shutdown(1)
				end_time = Time.now
			rescue Exception => exception
				mylog.error "Failure While Writing Outbound Data: #{exception}"
			end

			logline = "#{start_time} (#{read_time.to_f - start_time.to_f}/#{end_time.to_f - start_time.to_f}) :: #{request.uri} \"#{status[0]}\" #{response.body.length}B"
			#mylog.info logline
		else
			response = Iowa::Response.new(500)
			response.body = status[1]
			message = Marshal.dump(response)
			socket.write(message)
			socket.flush
			socket.shutdown(1)
			logline = "#{start_time} (#{read_time.to_f - start_time.to_f}/#{end_time.to_f - start_time.to_f}) :: #{request.uri} ERROR #{response.body.length}B"
			mylog.info logline
		end
	end

	# Outputs the location of the socket being monitored, then enters the
	# event loop to wait for and handle connections.

	def self.eventLoop(server)
		Logger[Ciowa_log].info 'Entering the main event loop...'
		loop do
			socket = server.accept
			Thread.start do
				Thread.current[:worker] = true
				handleConnection socket
			end
		end
	end

	# Outputs the location of the socket being monitored, then enters the
	# event loop to wait for and handle connections.

	def self.to_hex(n)
		sprintf('%02s',n.to_i.to_s(16)).sub(' ','0')
	end
	
	def self.run_check_started(*args)
		unless started?
			# Not started yet; call startDaemon()
			if args[0].is_a?(::Hash)
				# Pretty argument passing
				ah = args.shift
				daemonize = ah[:daemonize] ? true : false
				path = ah[:config] ? ah[:config] : args[0] ? args.shift.to_s : nil
				path = File.basename($0).sub(/\.\w+$/,'.cnf') unless path
			else
				daemonize = (args[0].is_a?(TrueClass) or args[0].is_a?(FalseClass)) ? args.shift : nil
				path = args[0] ? args.shift.to_s : nil
				path = File.basename($0).sub(/\.\w+$/,'.cnf') unless path
			end

			startDaemon(path,daemonize)
		end
	end

	def self.run(*args)
		run_check_started(*args)
		mylog = Logger[Ciowa_log]
		my_ip = @config[Csocket][Chostname]
		my_ip_hex = my_ip.split('.',4).collect {|x| to_hex(x)}.join

		if @config[Csocket].has_key? Cport
			socket_host = @config[Csocket][Chostname]
			socket_port = @config[Csocket][Cport]
			my_port_hex = sprintf('%04s',socket_port.to_i.to_s(16)).gsub(' ','0')
			begin
				# This should be configurable and runtime toggleable.
				TCPServer.do_not_reverse_lookup = true
				if socket_host.to_s == ''
					@server = TCPserver.new(socket_port)
					mylog.info "Listening at localhost:#{socket_port}."
				else
					@server = TCPserver.new(socket_host,socket_port)
					mylog.info "Listening at #{socket_host}:#{socket_port}."
				end
				app.location = "#{my_ip_hex}#{my_port_hex}"
			rescue Exception => exception
				mylog.fatal "Failure while attempting to establish a TCP socket at #{socket_host}:#{socket_port} : #{exception}"
				raise
			end
		else
			begin
				@server = UNIXServer.new(@config[Csocket][Cpath])
				File.chmod(0666, @config[Csocket][Cpath])
				mylog.info "Listening on #{@config[Csocket][Cpath]}."
			rescue Exception => exception
				mylog.fatal "Failure while attemting to establish a Unix socket at #{@config[Csocket][Cpath]} : #{exception}"
				raise
			end
			if app.serial_number.to_s != ''
				app.location = "00000000#{sprintf('%04s',Iowa.app.serial_number.to_i.to_s(16)).gsub(' ','0')}"
			else
				app.location = ''
			end
		end

		app.initialLoad()
		setup_signal_handlers

		begin
			eventLoop(@server)
		rescue Exception => exception
			mylog.fatal "Catastrophic failure in main event loop: #{exception} :: " + exception.backtrace.join(".....").to_s
		ensure
			@server.close if @server
			File.delete(@config[Csocket][Cpath]) if @config[Csocket].has_key? Cpath
		end
	end

	def Iowa.app
		if @app
			@app
		else
			@app = Application.newApplication(Dir.getwd)
		end
	end

	def Iowa.config
		@config
	end

	def self.setup_signal_handlers
		# A clean shutdown will wait up to a minute for any existing worker threads
		# to finish before shutting down.
		Logger['iowa_log'].info "Setting up signal handlers."

		trap("INT") {Iowa.clean_shutdown}
		trap("TERM") {Iowa.clean_shutdown}
	end

	def self.clean_shutdown
		# If, for whatever reason, this is taking too long, a second signal will
		# cause it to shut down immediately.

		# A dirty shutdown doesn't wait for anything to finish.
		
		trap("INT") { Iowa.dirty_shutdown }
		trap("TERM") { Iowa.dirty_shutdown }
		Logger['iowa_log'].info "Shutting down."

		@server.close if @server and @server.respond_to?(:close)
		threads_running = true
		count = 0
		while threads_running
			# Don't wait forever....
			count += 1
			break if count > 30
			threads_running = false
			Thread.list.each {|t| threads_running = true if t[:worker] and t.alive?}
			Logger['iowa_log'].info "  ...still waiting for #{thread_count} threads." if threads_running
			sleep 2 if threads_running
		end
		File.delete(@config[Csocket][Cpath]) if @config[Csocket].has_key? Cpath
	ensure
		Logger['iowa_log'].info "Clean shutdown."
		Iowa::Log.close
		::Process.exit!
	end

	def self.thread_count
		r = 0
		Thread.list.each {|t| r += 1 if t[:worker] and t.alive?}
		r
	end

	def self.dirty_shutdown
		@server.close unless !@server or !server.respond_to(:close) or (@server and @server.closed?)
		File.delete(@config[Csocket][Cpath]) if @config[Csocket].has_key? Cpath
	ensure
		Logger['iowa_log'].info "Dirty shutdown."
		Iowa::Log.close
		::Process.exit!
	end

	def self.runmode
		@runmode
	end

	def self.runmode=(mode)
		@runmode = mode
	end

end

OptionParser.new do |opts|
	opts.banner = 'Usage: scriptname.rb [options]'
	opts.separator ''
	opts.on('-r','--run [MODE]', [:marshal, :webrick, :mongrel, :httpmachine, :hybrid, :hybridcluster],
		"Select run mode (marshal, webrick, mongrel, httpmachine, hybrid); defaults to standalone") do |m|
		case m
		when :webrick
			require 'iowa_webrick'
		when :mongrel
			require 'iowa_mongrel'
		when :httpmachine
			require 'iowa_httpmachine'
		when :hybrid
			require 'iowa_hybrid'
		when :hybridcluster
			require 'iowa_hybrid_cluster'
		when :marshal
			Iowa.runmode = :marshal
		else
			require 'webrick'
			Iowa.runmode = :webrick
		end
	end
	opts.on('-p','--port [NUMBER]',Integer,"Port to run IOWA process on") do |m|
		Iowa.config[::Iowa::Csocket][::Iowa::Cport] = m
	end
	opts.on('-h','--host [HOST]',String,"Hostname or IP address to bind to") do |m|
		Iowa.config[::Iowa::Csocket][::Iowa::Chost] = m
	end

end.parse!

unless Iowa.runmode
	require 'iowa_webrick'
end
