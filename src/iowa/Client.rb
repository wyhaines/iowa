# Iowa::Client encapsulates the methods necessary to make a connection
# to an Iowa servlet, receive the response back from the servlet, and to
# deliver that response.

require 'socket'
require 'iowa/Request'
require 'iowa/Response'
require 'iowa/Constants'
require 'time'

module Iowa

	class Client

		EX_HEADERS = {CDate => true, CServer => true, CConnection => true, CContent_Type => true} unless const_defined?(:EX_HEADERS)

		# When an Iowa::Client is created, it takes as its argument a
		# socket definition.  It uses that definition to establish either
		# a TCPSocket or a UNIXSocket to the servlet.
		#
		# The socket defenition can be either in the form of:
		#   hostname:port
		# or it can be a filesystem path.  If one uses the hostname:port
		# form, then a TCPSocket will be used.  Otherwise, a UNIXSocket
		# will be used.
		
		def initialize(sp)
			@start_time = Time.now
			socket_path = sp.dup
			socket_path.untaint
			tcp_pattern = Regexp.new('^([^:]*):(\d+)')
			tcp_match = tcp_pattern.match(socket_path)
			if tcp_match
				# Connect to a TCP socket.
				socket_host = tcp_match[1]
				socket_port = tcp_match[2]
				TCPSocket.do_not_reverse_lookup = true
				@socket = TCPSocket.new(socket_host,socket_port)
			else
				@socket = UNIXSocket.new(socket_path)
			end
		end

		# One calls initiate() to send the request off to the servlet.
		
		def initiate(request=nil)
			@request = Iowa::Request.new_request(request)
File.open("/tmp/cgi.out","a+") {|fh| fh.puts "Client in #{@request.inspect}"}
			m = Marshal.dump(@request)
			@socket.write(m)
			@socket.flush
			@socket.shutdown(1)
		end

		# This receives the response back from the servlet.
		
		def receive
			m = ''
			while (recv = @socket.recv(8192)) != ""
			  m << recv
			end
			@socket.close
			@socket = nil
File.open("/tmp/cgi.out","a+") {|fh| fh.puts "Client out #{m}"}
			@response = Marshal.load(m)
File.open("/tmp/cgi.out","a+") {|fh| fh.puts "Client out #{@response.inspect}"}
			@response.content_type = Ctext_html unless @response.content_type.to_s != C_empty
		end

		# Prints/sends the HTTP headers for the response.
		
		# This path selection for how to output the data is UGLY.  Make it better.
		def printHeaders(ios=nil)
			@response.calculate_runtime = false unless @response.content_type == Ctext_html
			@response.content.sub!(/^[\s\r\n]*/m,C_empty)
			calculate_runtime if @response.calculate_runtime
			if ENV[CMOD_RUBY]
				r = Apache.request
				r.content_type = @response.content_type
				r.status_line = @response.status_line if @response.status_line
				r.status = @response.status if @response.status
				@response.headers_out.each do |key,value|
					r.headers_out.set(key,value.to_s)
				end
				r.headers_out.set(CContent_Length,@response.content.length.to_s)
				r.send_http_header
			elsif ::Object.const_defined?(:Mongrel) and !::Object.const_defined?(:EventMachine)
				ios.status = @response.status
#				@response.headers_out[CDate] ||= Time.now.httpdate
				@response.headers_out[CExpires] ||= Time.now.httpdate
				ioshead = ios.header
			 	ioshead.out << "#{CContent_Type}: #{@response.content_type}\r\n"
#				@response.headers_out[CContent_Length] = @response.content.length unless @response.headers_out[CContent_Length]
				@response.headers_out.each do |key, value|
					ioshead.out << "#{key}: #{value}\r\n"
				end
			elsif ios
				outbuf = ''
				@response.headers_out[CDate] ||= Time.now.httpdate
				@response.headers_out[CExpires] ||= @response.headers_out[CDate]
				outbuf << "Date: #{@response.headers_out[CDate]}\r\n"

				@response.headers_out[CContent_Length] = @response.content.length unless @response.headers_out[CContent_Length]

				@response.headers_out.each do |key, value|
					next if EX_HEADERS.has_key? key
					outbuf << "#{key}: #{value}\r\n"
				end
				outbuf << "Content-Type: #{@response.content_type}\r\n\r\n"
				ios.print outbuf
			else
				@response.headers_out[CDate] ||= Time.now.httpdate
				@response.headers_out[CExpires] ||= @response.headers_out[CDate]
#				@response.headers_out[CServer] ||= ENV['SERVER_SOFTWARE']
				puts "Date: #{@response.headers_out['Date']}"
				puts "Content-Type: #{@response.content_type}"
				if @response.headers_out['Content-Length']
					EX_HEADERS['Content-Length'] = true
				else
					puts "Content-Length: #{@response.content.length}"
				end
				@response.headers_out.each do |key, value|
					next if EX_HEADERS.has_key? key
					puts "#{key}: #{value}"
				end
				puts ""
			end
		end

		# Deliver the content of the request.
		
		def printBody(ios=nil)
			unless @request.request_method == CHEAD
				if ios
					if ::Object.const_defined?(:Mongrel) and !::Object.const_defined?(:EventMachine)
						ios.body << @response.content
					else
						ios.print @response.content
					end
				else
					puts @response.content
				end
			end
		end

		def clearOld
			@socket = nil
			@request = nil
			@response = nil
		end
		
		# Deliver both the header and the content of the request, then clear
		# the client.
		
		def print(ios = nil)
			printHeaders(ios)
			printBody(ios)
			clearOld
		end
		
		def calculate_runtime
			@runtime = Time.now - @start_time
			@response.content << "\n<!-- #{@runtime} -->\n"
		end
		
		def handle_request(args = {:request => nil, :ios => nil})
			initiate(args[:request])
			receive
			print(args[:ios])
		end
	end

	# An InlineClient doesn't do any socket communications.  It just handles printing
	# a response.
	class InlineClient < Client
		def initialize(request,response)
			@request = request
			@response = response
			@start_time = Time.now
		end

		def reset(request,response)
			@request = request
			@response = response
			@start_time = Time.now
		end

		def initiate; end
		def receive; end

		def handle_request(args = {:ios => nil})
			print(args[:ios])
		end
	end
end
