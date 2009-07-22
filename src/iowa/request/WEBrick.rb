require 'iowa/Request'

module Iowa

	class Request

		class WEBrick < Iowa::Request

			def setup(request)
				@hostname = request.host
				@unparsed_uri = request.unparsed_uri
				#@uri = request.path.to_s
				@uri = request.path_info
				@request_time = request.request_time
				@request_method = request.request_method
				@remote_host = request.peeraddr[2]
				@remote_addr = request.peeraddr[3].split(':')[3]
				@filename = request.path
				@header_only =  (@request_method.to_s == 'HEAD') ? true : false
				@args = request.query_string
				@params = {}
				request.query.each do |k,v|
					@params[ k ] = v.list.length > 1 ? v.list.join("\0") : v
				end
				@headers = @headers_in = Iowa::DataTable.new	
				request.header.each {|k,v| @headers_in[k] = v}

				@status_line = nil
				@headers_out = Iowa::DataTable.new
				@content_type = nil
				@content_encoding = nil
				@content_languages = nil
				@content = ''
			end

			def initialize(request)
				@calculate_runtime = false

				setup(request)
			end

		end

	end

end

Iowa::Request.Type = Iowa::Request::WEBrick
