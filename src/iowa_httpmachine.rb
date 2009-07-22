Iowa.runmode = :httpmachine
require 'rubygems'
require 'eventmachine'
require 'evma_httpserver'
require 'iowa/Client'
require 'iowa/request/HTTPMachine'

module Iowa
	class HttpEventMachine < ::EventMachine::Connection
		include ::EventMachine::HttpServer

		def initialize(*args)
			@iowa_client = Iowa::InlineClient.new(nil,nil)
			super
		end

		def deliver_file(filename, suffix)
				send_data "HTTP/1.1 200 OK\r\n"
				d = File.read(filename)
				ct = MIME::Types.type_for(filename).first
				send_data "Connection: close\r\n"
				send_data "Date: #{Time.now.httpdate}\r\n"
				send_data "Content-Type: #{ct ? ct.content_type : 'application/octet-stream'}\r\n"
				send_data "Content-Length: #{d.length}\r\n\r\n"
				send_data d
				close_connection_after_writing
				Logger['iowa_log'].info "Delivered static file: #{filename}"
		end

		def handle_file(path_info)
			if path_info == '/' or path_info == ''
				path_info = '/index.html'
			elsif path_info =~ /^([^.]+)$/
				path_info = "#{$1}/index.html"
			end

			qsfilename = "#{Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}__#{ENV['QUERY_STRING']}"
			filename = "#{Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}"

			if (FileTest.exist?(qsfilename) and File.expand_path(qsfilename).index(Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
				deliver_file(qsfilename, path_info.sub(/_*$/,'').split(/\./).last)
				true
			elsif (FileTest.exist?(filename) and  File.expand_path(filename).index(Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
				deliver_file(filename, path_info.sub(/_*$/,'').split(/\./).last)
				true
			else
				false
			end
		end

		def process_http_request
			unless handle_file(@http_path_info)
				request = Iowa::Request::HTTPMachine.new([@http_request_method, @http_request_uri, @http_headers])
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

	end
end

module Iowa

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
		Logger[Ciowa_log].info 'Entering the httpmachine event loop...'
		::EventMachine.run {
		  ::EventMachine.start_server(@config[Csocket][Chostname], @config[Csocket][Cport], ::Iowa::HttpEventMachine)
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
