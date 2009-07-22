require 'iowa/Request'
require 'iowa/Util'

module Iowa

	class Request

		class ENV < Iowa::Request

			def setup
				@hostname = ::ENV['SERVER_NAME']
				@unparsed_uri = @uri = ::ENV['REQUEST_URI']
				@filename = ::ENV['SCRIPT_FILENAME']
				@request_time = Time.now.asctime
				@request_method = ::ENV['REQUEST_METHOD']
				#@remote_host = ::ENV['REMOTE_HOST']
				#@remote_addr = ::ENV['REMOTE_ADDR']
				@headers_only = (@request_method.to_s == 'HEAD') ? true : false
				@params = {}

				# CGI will give us a hash of the params, but @args is supposed
				# to be a String.
				@params = parse_params
				if @request_method == CPOST
					@params.each_pair do |k,v|
						if (v.class.name == 'StringIO') or (v.class.name == 'Tempfile')
							@params[k] = Iowa::FileData.new(v.original_filename,v.content_type,v.read)
						end
					end
				end
				@args = @request_method == CPOST ? '' : @params.keys.collect {|i| "#{i}=#{@params[i]}"}.join('&')

				@headers_in = @headers = Iowa::DataTable.new	
				::ENV.each do |k,v|
					next unless k.index(CHTTP_) == 0
					key = k.dup
					key.sub!(/^HTTP_/,'')
					key.gsub!(/([^_]+_?)/) do |s|
						s.capitalize
					end
					@headers[key] = v
				end
				@content_type = nil
				@content_encoding = nil
				@content_languages = nil
			end

			def initialize(request=nil)
				setup
			end

			def parse_params
				req_meth = @request_method

# Add code supporting multipart.

				if req_meth == CGET or req_meth == CHEAD
					query = ::ENV[CQUERY_STRING] or C_empty
				else
					$stdin.binmode if defined? $stdin.binmode
					query = $stdin.read(Integer(::ENV[Iowa::CCONTENT_LENGTH])) or C_empty
				end

				params = Hash.new([].freeze)
				query.split(/[&;]/n).each do |pairs|
					key, value = pairs.split(C_equal,2).collect{|v| Util::unescape(v) }
					if params.has_key?(key)
						params[key].push(value)
					else
						params[key] = [value]
					end
				end
				params
			end

		end
	end
end

Iowa::Request.Type = Iowa::Request::ENV
