require 'iowa/Request'

module Iowa

	class Request

		class Apache < Iowa::Request

			def aah_to_a(val)
				return val unless val.is_a?(::Apache::ArrayHeader)
				r = []
				val.each {|v| r << v}
				r
			end

			def setup(request)
				@hostname = request.hostname
				@unparsed_uri = request.unparsed_uri
				@uri = request.uri
				@filename = request.filename
				@request_time = request.request_time
				@request_method = request.request_method
				@header_only = request.header_only?
				# In an Apache::Request object, request.args is a string.  We want
				# to make a hash of these contents available for use, too.
				@args = request.args
				@args = '' if args.nil?
				@content_type = request.content_type
				@content_encoding = request.content_encoding
				@content_languages = aah_to_a(request.content_languages)
				@remote_host = request.remote_host(::Apache::REMOTE_HOST)
				@remote_addr = request.remote_host(::Apache::REMOTE_NOLOOKUP)
				@auth_type = request.auth_type
				@auth_name = request.auth_name
				@cache_resp = request.cache_resp
				@params = Hash.new
				if @args.to_s != C_empty
					@args.split(/&/).each do |a|
						k,v = a.split(/=/,2).collect{|x| Iowa::Util.unescape(x)}
						if @params.has_key? k
							if @params[k].respond_to?(:push)
								@params[k] << (v or C_empty)
							else						    
								@params[k] = [(v or C_empty)]
							end
						else
							@params[k] = (v or C_empty)
						end
					end
				else
					if m = MIMERegexp.match(request.headers_in['Content-Type'])
						boundary = m[1]
						@params = read_multipart(boundary,request.headers_in['Content-Length'],$stdin,request.headers_in['HTTP_USER_AGENT'])
					else
						@content = $stdin.read
						@content = '' if @content.nil?
						@content.split(/[&;]/).each do |x|
							key, val = x.split(/=/,2).collect{|x| Iowa::Util.unescape(x)}
							if @params.include?(key)
								@params[key] += "\0" + (val or "")
							else
								@params[key] = (val or "")
							end
						end
					end
				end
				@headers = Iowa::DataTable.new
				request.headers_in.each do |key,value|
					@headers[key] = value
				end
				#@status_line = request.status_line
				#@headers_out = Iowa::DataTable.new
				#request.headers_out.each do |key,value|
				#	@headers_out[key] = value
				#end
			end

			def initialize(request=nil)
				unless request
					request = Apache.request if ENV['MOD_RUBY']
				end

				setup(request)
			end

		end
	end
end

Iowa::Request.Type = Iowa::Request::Apache
