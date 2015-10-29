# -*- coding: ISO-8859-1 -*-
require 'iowa/Request'
require 'time'

module Iowa

	class Request

		# This class encapsulates an EM Hybrid request.  This is a request that
		# was received by EventMachine but was parsed by the Mongrel HTTP
		# parser.
		
		class EMHybrid < Iowa::Request

			def setup(headers,params,body)
				hn = headers[CX_FORWARDED_HOST] || headers[CHTTP_HOST] || headers[CHOST]
				@hostname,@port = hn.split(/:/)
				@unparsed_uri = params[CREQUEST_URI]
				@uri = params[CREQUEST_URI].gsub(/\?.*$/,'')
				#@uri = params[CPATH_INFO]
				@request_time = Time.now.httpdate
				@request_method = params[CREQUEST_METHOD]
				#@remote_host = request.params[::Mongrel::Const::REMOTE_HOST]
				#@remote_addr = request.params[::Mongrel::Const::REMOTE_ADDR]
				@header_only =  (@request_method == CHEAD) ? true : false
				@args = params[CQUERY_STRING]

				@headers_in = @headers = headers
				
				@params = {}
				if m = MIMERegexp.match(@headers[CContent_type])
					boundary = m[1]
					@params = read_multipart(boundary,@headers[CContent_length],body,@headers[CUser_agent])
				else
					body.each_line {|line| parse_params(line)}
				end

				parse_params(@args) if @args
				
				@status_line = nil
				@headers_out = Iowa::DataTable.new
				@content_type = nil
				@content_encoding = nil
				@content_languages = nil
				@content = ''
			end

			def initialize(headers,params,body)

				@calculate_runtime = false

				setup(headers,params,body)
			end

		end
	end
end

Iowa::Request.Type = Iowa::Request::EMHybrid

