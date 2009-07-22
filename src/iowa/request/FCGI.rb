require 'iowa/Request'

module Iowa

	class Request

		class FCGI < Iowa::Request

			def setup(request)
				env = request.env
				@hostname = env['SERVER_NAME']
				@unparsed_uri = @uri = env['REQUEST_URI']
				@filename = env['SCRIPT_FILENAME']
				@request_time = Time.now.asctime
				@request_method = env['REQUEST_METHOD']
				@remote_host = env['REMOTE_HOST']
				@remote_addr = env['REMOTE_ADDR']
				@headers_only = (@request_method.to_s == 'HEAD') ? true : false
				@params = {}

				if @args = env['QUERY_STRING'] != ''
					@args.split(/[&;]/).each do |a|
						k,v = a.split('=',2).collect{|x| Iowa::Util.unescape(x)}
						if @params.has_key? k
							@params[k] += "\0" + (v or "")
						else
							@params[k] = (v or "")
						end
					end
				end

				if m = MIMERegexp.match(env['CONTENT_TYPE'])
					boundary = m[1]
					@params = read_multipart(boundary,env['CONTENT_LENGTH'],request.in,env['USER_AGENT'])
				else
					@content = request.in.read
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
				@headers = Iowa::DataTable.new
				@params.each do |k,v|
					next unless k =~ /^HTTP_/
					key = k.dup
					key.sub!(/^HTTP_/,'')
					key.gsub!(/([^_]+_?)/) do |s|
						s.gsub('_','-').capitalize
					end
					@headers.set(key,@params[key])
				end
				@content_type = nil
				@content_encoding = nil
				@content_languages = nil
			end

			def initialize(request=nil)
				setup(request)
			end

		end
	end
end
