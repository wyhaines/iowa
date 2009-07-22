require 'mime/types'
require 'iowa/Util'
require 'iowa/String'

module Iowa

	class Response
		BINARY_TYPE = MIME::Types.type_for('bin') unless const_defined?(:BINARY_TYPE)

		# Based on info at http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
		unless const_defined?(:RESPONSE_CODES)
		RESPONSE_CODES = {
			100 => 'Continue',
			101 => 'Switching Protocols',
			200 => 'OK',
			201 => 'Created',
			202 => 'Accepted',
			203 => 'Non-Authoritative Information',
			204 => 'No Content',
			205 => 'Reset Content',
			206 => 'Partial Content',
			300 => 'Multiple Choices',
			301 => 'Moved Permanently',
			302 => 'Moved Temporarily',
			303 => 'See Other',
			304 => 'Not Modified',
			305 => 'Use Proxy',
			307 => 'Temporary Redirect',
			400 => 'Bad Request',
			401 => 'Unauthorized',
			402 => 'Payment Required',
			403 => 'Forbidden',
			404 => 'Not Found',
			405 => 'Method Not Allowed',
			406 => 'Not Acceptable',
			407 => 'Proxy Authentication Required',
			408 => 'Request Timeout',
			409 => 'Conflict',
			410 => 'Gone',
			411 => 'Length Required',
			412 => 'Precondition Failed',
			413 => 'Request Entity Too Large',
			414 => 'Request-URI Too Long',
			415 => 'Unsupported Media Type',
			416 => 'Requested Range Not Satisfiable',
			417 => 'Expectation Failed',
			500 => 'Internal Server Error',
			501 => 'Not Implemented',
			502 => 'Bad Gateway',
			503 => 'Service Unavailable',
			504 => 'Gateway Timeout',
			505 => 'HTTP Version Not Supported'} 
			RESPONSE_CODES.each {|k,v| const_set(Iowa::String.new(v.gsub('-','_')).constant_case,k)}
		end

		attr_accessor :body, :calculate_runtime
		alias :content :body
		alias :content= :body=

		def initialize(code=200, out = '')
			self.status = code
			@content_type = Ctext_html
			@body = out
			@headers = Iowa::DataTable.new
			@calculate_runtime = false
		end

		def headers
			@headers
		end

		def headers_out
			@headers
		end

		def content_type
			@content_type
		end

		# If given a complete type, such as 'text/csv', the type will be set as it
		# was given.  If given an incomplete type, such as 'gif' or 'csv', the type
		# will be deduced or, if it can't be deduced, set to application/octet-stream.
		
		def content_type=(type)
			if type.index(C_slash)
				@content_type = type
			else
				@content_type = MIME::Types.type_for(type).first || BINARY_TYPE
			end
		end

		def status
			@status
		end

		def status=(code)
			if (rc = RESPONSE_CODES[code])
				@status_line = "#{code} #{rc}"
				@status = code
			else
				@status = 200
				@status_line = '200 OK'
			end
		end

		def status_line
			@status_line
		end

		def status_line=(s)
			s.gsub(/^\s*(\d+)\s+/) {self.status = $1.to_i; ''}
		end

		def <<(val)
			@body << val
		end

		def cookie(name, val, args = {:path => C_slash})
			parts = ["#{name}=#{val}"]
			args.each {|k,v| parts << ["#{k}=#{v}"]}
			self['Set-Cookie'] = parts.join(C_semicolon)
		end
		
		def [](val)
			@headers.get(val)
		end

		def []=(k,v)
			@headers.set(k,v)
		end
	end
end
