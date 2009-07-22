Iowa.runmode = :emhybrid
require 'eventmachine'
require 'iowa/http11'
require 'iowa/Client'
require 'iowa/request/EMHybrid'


module Iowa 
	class EMHybridServer < EventMachine::Connection
		
		def initialize *args
			super
			@linebuffer = ''
			@iowa_client = Iowa::InlineClient.new(nil,nil)
		end

		def deliver_file(filename, suffix)
			send_data "HTTP/1.1 200 OK\r\n"
			d = File.read(filename)
			ct = MIME::Types.type_for("foo.#{suffix}").first
			send_data "Connection: close\r\n"
			send_data "Date: #{Time.now.httpdate}\r\n"
			send_data "Content-Type: #{ct ? ct.content_type : 'application/octet-stream'}\r\n"
			send_data "Content-Length: #{d.length}\r\n\r\n"
			send_data d
			close_connection_after_writing
			Logger[Ciowa_log].info "Delivered static file: #{filename}"
		end

		def handle_file(params)
			path_info = params[CREQUEST_URI]
			qs = params[CQUERY_STRING]
			if path_info == C_slash or path_info == C_empty
				path_info = C_slashindex_html
			elsif path_info =~ /^([^.]+)$/
				path_info = "#{$1}/index.html"
			end

			qsfilename = "#{Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}__#{qs}"
			filename = "#{Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}"
			if (FileTest.exist?(filename) and  File.expand_path(filename).index(Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
				suffix = path_info.sub(/[_\s]*$/,C_empty)
				deliver_file(filename, File.extname(suffix)[1..-1])
				true
			elsif qs and (FileTest.exist?(qsfilename) and File.expand_path(qsfilename).index(Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
				suffix = path_info.sub(/[_\s]*$/,C_empty)
				deliver_file(qsfilename, File.extname(suffix)[1..-1])
				true
			else
				false
			end
		end
		
		def post_init
			@parser = Iowa::HttpParser.new
			@params = {}
			@headers = {}
			@nparsed = 0
			@request = nil
			@request_len = nil
		end

		def unbind
			# cleanup here
		end

		def process_http_request(headers,params,buffer)
			unless handle_file(params)
				clen = buffer.length - headers[CCONTENT_LENGTH].to_i
				body = buffer[clen,headers[CCONTENT_LENGTH].to_i]
				request = Iowa::Request::EMHybrid.new(headers,params,body)
				response = Iowa.handleConnection request

				@iowa_client.reset(request,response)
				send_data "HTTP/1.1 #{response.status_line}\r\n"
				@iowa_client.print(self)
				close_connection_after_writing
			end
		end

		def print(data)
			send_data data
		end
		
		def receive_data data
			@linebuffer << data
			@nparsed = @parser.execute(@headers, @params, @linebuffer, @nparsed) unless @parser.finished?
			if @parser.finished?
				if @request_len.nil? or (@linebuffer.length >= @request_len)
					@request_len = @nparsed + @headers[CCONTENT_LENGTH].to_i
		    	if @linebuffer.length >= @request_len
        		process_http_request(@headers,@params,@linebuffer)
    			end
				end
			end
		rescue => e
			Logger['iowa_log'].error "Error while reading request: #{e}"
			close_connection
		end
	end
end

module Iowa

	# Handle the communications coming in on the monitored socket,
	# create a context object from the data received, and then pass
	# the context information into the Application object for final
	# handling.  Exception handling is simply via capturing the Exception
	# and outputting a stack backtrace (this could be improved).

	class << self
		remove_method(:handleConnection)
		remove_method(:eventLoop)
		remove_method(:run)
	end

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
		Logger[Ciowa_log].info 'Entering the EMHybrid event loop...'
		::EventMachine.run {
		  ::EventMachine.start_server @config[Csocket][Chostname], @config[Csocket][Cport], EMHybridServer
		}
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
