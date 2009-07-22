Iowa.runmode = :mongrel
require 'mongrel'
require 'mongrel/handlers'
require 'iowa/request/Mongrel'
require 'iowa/Client'

Socket.do_not_reverse_lookup = true

module Iowa
	class MongrelHandler < ::Mongrel::HttpHandler
		def initialize(config)
			@config = config
			@filemap = {}
		end

		def deliver_file(filename,suffix,res)
			res.status = 200
			ct = MIME::Types.type_for("foo.#{suffix}").first
			res.header['Content-Type'] = ct ? ct.content_type : 'application/octet-stream'
			res.body << File.read(filename)
			Logger['iowa_log'].info "Delivered static file: #{filename}"
		end

		def handle_file(req, res)
			path_info = req.params['PATH_INFO']
			if path_info == '/' or path_info == ''
				path_info = '/index.html'
			elsif path_info =~ /^([^.]+)$/
				path_info = "#{$1}/index.html"
			end

			qsfilename = "#{@config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}__#{req.params['QUERY_STRING']}"
			filename = "#{@config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}"
			
			if (FileTest.exist?(qsfilename) and File.expand_path(qsfilename).index(@config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
				suffix = path_info.sub(/[_\s]*$/,C_empty)
				deliver_file(filename, File.extname(suffix)[1..-1],res)
				true
			elsif (FileTest.exist?(filename) and  File.expand_path(filename).index(@config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
				suffix = path_info.sub(/[_\s]*$/,C_empty)
				deliver_file(filename, File.extname(suffix)[1..-1],res)
				true
			else
				false
			end
		end

		def process(req, res)
			Thread.current[:worker] = true
			unless handle_file(req, res)
				request = Iowa::Request::Mongrel.new(req)
				response = Iowa.handleConnection request
				::Iowa::InlineClient.new(request,response).print(res)
			end
		end
	end



	# Handle the communications coming in on the monitored socket,
	# create a context object from the data received, and then pass
	# the context information into the Application object for final
	# handling.  Exception handling is simply via capturing the Exception
	# and outputting a stack backtrace (this could be improved).

	def self.handleConnection(request)
		start_time = read_time = Time.now
		mylog = Logger[Ciowa_log]

		status = []
		response = handleRequest(request)
		begin
			response.status_line = request.status_line if request.status_line
			response.content_type = request.content_type if request.content_type
			status[0] = response.status_line
			if request.headers_out.respond_to?(:length) and request.headers_out.length > 0
				request.headers_out.each {|k,v| response.headers.set(k,v)}
			end
		rescue Exception => e
			mylog.info e.to_s, e.backtrace.inspect
		end

		end_time = Time.now
		logline = "#{start_time} (#{read_time - start_time}/#{end_time - start_time}) :: #{request.uri} \"#{status[0]}\" #{response.body.length}B"
		mylog.info logline
		response
	end

	# Outputs the location of the socket being monitored, then enters the
	# event loop to wait for and handle connections.

	def self.eventLoop
		Logger[Ciowa_log].info 'Entering the mongrel event loop...'
		@mongrel.run
		@mongrel_thread = @mongrel.acceptor
		@mongrel_thread.join
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
			Iowa.app.location = "#{my_ip_hex}#{my_port_hex}"
		else
			if Iowa.app.serial_number.to_s != ''
				Iowa.app.location = "00000000#{sprintf('%04s',Iowa.app.serial_number.to_i.to_s(16)).gsub(' ','0')}"
			else
				Iowa.app.location = ''
			end
		end

		mongrel_options = {:BindAddress => @config[Csocket][Chostname],
			:Port => @config[Csocket][Cport],
			:DocumentRoot => "#{@config[Capplication][Croot_url]}/doc"}
		@mongrel = ::Mongrel::HttpServer.new(mongrel_options[:BindAddress], mongrel_options[:Port])
		@mongrel.register('/', MongrelHandler.new(@config))

		app.initialLoad()
		@server = nil
		setup_signal_handlers

		begin
			eventLoop
		rescue Exception => exception
			mylog.fatal "Catastrophic failure in main event loop: #{exception} :: " + exception.backtrace.join(".....").to_s
		ensure
			File.delete(@config[Csocket][Cpath]) if @config[Csocket].has_key? Cpath
		end
	end
end
