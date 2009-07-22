require 'iowa/Request'
require 'time'

module Iowa

	class Request

		# This class encapsulates a Mongrel request.  Mongrel just dumps all
		# of the HTTP headers into the environment, CGI-style, so the ones
		# that are necessary are extracted from the environment, as are the
		# HTTP headers received from the web server.  The params are parsed
		# out of the request body.  Will handle mime multipart.
		class Mongrel < Iowa::Request

			def setup(request)
				params = request.params
				hn = params[CX_FORWARDED_HOST] || params[CHTTP_HOST]
				@hostname,@port = hn.split(/:/)
				@hostname = params[CSERVER_NAME]
				@unparsed_uri = params[::Mongrel::Const::REQUEST_URI]
				@uri = params[::Mongrel::Const::PATH_INFO]
				@request_time = Time.now.httpdate
				@request_method = params[::Mongrel::Const::REQUEST_METHOD]
				#@remote_host = params[::Mongrel::Const::REMOTE_HOST]
				#@remote_addr = params[::Mongrel::Const::REMOTE_ADDR]
				@header_only =  (@request_method == CHEAD) ? true : false
				@args = params[CQUERY_STRING]

				@headers_in = @headers = Iowa::DataTable.new	
				params.each do |k,v|
					next unless k =~ /^HTTP_/
					key = k.dup
					key.sub!(/^HTTP_/,'')
					key.gsub!(/([^_]+_?)/) do |s|
						s.gsub('_','-').capitalize
					end
					@headers[key] = v
				end
				
				@params = {}
				if m = MIMERegexp.match(@headers[CContent_type])
					boundary = m[1]
					@params = read_multipart(boundary,@headers[CContent_length],request.body,@headers[CUser_agent])
				else
					request.body.each {|line| parse_params(line)}
				end
				parse_params(@args) if @args
				
				@status_line = nil
				@headers_out = Iowa::DataTable.new
				@content_type = nil
				@content_encoding = nil
				@content_languages = nil
				@content = ''
			end

			def initialize(request=nil)

				@calculate_runtime = false

				setup(request)
			end

		end
	end
end

Iowa::Request.Type = Iowa::Request::Mongrel
