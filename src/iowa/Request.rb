require 'iowa/Util'
require 'tempfile'

module Iowa

	# A DispatchDestination is a simple container for information on
	# where a request is being dispatched to.
	
	class DispatchDestination
		attr_accessor :component, :method, :args

		def initialize(c=nil, m=nil, a=[])
			@component = c
			@method = m
			@args = a
		end
	end

	# Class to encapsulate the data received from a file upload.
	
	class FileData < Array
	
		attr_accessor :name, :content_type
		
		def initialize(name,content_type,*content)
			@name = name
			@content_type = content_type
			content.each {|piece| self << piece}
		end
		
		def to_s # could get heavy on the RAM if the file is big.
			r = ''
			self.each do |piece|
				if Tempfile === piece || StringIO === piece
					piece.rewind
					r << piece.read
				else
					r << piece
				end
			end
		end

		# Create a file with a path/name as in @name, and write the current
		# data to it.  Convenience method.
		# After an Iowa app received an uploaded file and it checks/sets
		# @name as appropriate, a single call to store() will write the file.
		# If @name is blank or nil, the content will instead be written to
		# an instance of Tempfile.
				
		def store
			handle = nil
			
			# Make sure you know what is in @name before calling this!
			@name = @name.to_s
			
			if @name == ''
				handle = Tempfile.new('IowaFile')
			else
				handle = File.new(@name,'w+')
			end
			
			if handle
				self.each do |piece|
					if Tempfile === piece || StringIO === piece
						piece.rewind
						handle.write piece.read
					else
						handle.write piece
					end
				end
				handle.rewind
			end
			
			handle
		end
			
	end

# A serializeable class that represents (most of) the contents of
# an Apache::Request object.

	class Request

		MIMERegexp = %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n
		CR  = "\015"
		LF  = "\012"
		EOL = CR + LF
  
		attr_accessor :hostname, :port, :unparsed_uri, :uri, :filename, :request_time,
			:request_method, :header_only, :args, :params,
			:status_line, :headers_out, :content_type, :content_encoding
		attr_accessor :content, :auth_type, :auth_name, :remote_host,
			:cache_resp, :content_encoding, :content_languages, :remote_addr,
			:calculate_runtime, :headers_in, :context

		def Request.Type
			@request_type
		end

		def Request.Type=(val)
			@request_type = val
		end
		
		def read_multipart(boundary, content_length, instream, user_agent)
			content_length = content_length.to_i
			params = Hash.new([])
			boundary = "--" + boundary
			buf = ""
			bufsize = 10 * 1024

			# start multipart/form-data
			instream.binmode if defined? instream.binmode
			boundary_size = boundary.size + EOL.size
			content_length -= boundary_size
			status = instream.read(boundary_size)
	
			loop do
				head = nil
				body = ''
				filename = nil
	
				until head and /#{boundary}(?:#{EOL}|--)/n.match(buf)
					if (not head) and /#{EOL}#{EOL}/n.match(buf)
						buf = buf.sub(/\A((?:.|\n)*?#{EOL})#{EOL}/n) do
							head = $1.dup
							/Content-Disposition:.* filename="?([^\";]*)"?/ni.match(head)
							filename = (($1 && $1.any? && $1) || nil)

							if /Mac/ni.match(user_agent) && /Mozilla/ni.match(user_agent) && (! /MSIE/ni.match(user_agent))
								filename = Iowa::Util.unescape(filename) if filename
							end
	
							if filename
								body = Tempfile.new("IOWA_multipart_file")
								body.binmode  if body.respond_to?(:binmode)
							end

							""
						end
						next
					end

					if head and ( (EOL + boundary + EOL).size < buf.size )
						body << buf[0 ... (buf.size - (EOL + boundary + EOL).size)]
						buf[0 ... (buf.size - (EOL + boundary + EOL).size)] = ""
					end
	
					c = if bufsize < content_length
						instream.read(bufsize) or ''
					else
						instream.read(content_length) or ''
					end
					if c.nil? || c.empty?
						raise EOFError, "bad content body"
					end
					buf << c
					content_length -= c.size
				end
	
				buf = buf.sub(/\A((?:.|\n)*?)(?:#{EOL})?#{boundary}(#{EOL}|--)/n) do
					body << $1
					if "--" == $2
						content_length = -1
					end
					""
				end
		
				/Content-type: (.*)/ni.match(head)
				content_type = ($1 or "")

				/Content-Disposition:.* name="?([^\";]*)"?/ni.match(head)
				name = $1.dup
	
				data = nil
				if filename
					data = Iowa::FileData.new(filename,content_type,body)
				else
					data = body
				end
				if params.has_key?(name)
					if params[name].respond_to?(:push)
						params[name].push data
					else
						params[name] = [params[name]] << data
					end
				else
					params[name] = data
				end
				break if buf.size == 0
				break if content_length === -1
			end
	
			params
		end

		def parse_params(line)
			line.split(/&|;/).each do |pairs|
				key, value = pairs.split(Iowa::CR_equal,2).collect{|v| Iowa::Util.unescape(v) }
				if @params.has_key?(key)
					if @params[key].respond_to?(:push)
						@params[key] << value || Iowa::C_empty
					else
						@params[key] = [@params[key], value || Iowa::C_empty]
					end
				else
					@params[key] = value || Iowa::C_empty
				end
			end
		end
		
		# If there is a prefered Type set, return an instance of that type.
		# Otherwise, guess at a prefered Type, set it, then return an instance.
		
		def Request.new_request(request=nil)
			unless Iowa::Request.Type
				if ENV['MOD_RUBY']
					unless request
						request = Apache.request if ENV['MOD_RUBY']
					end
					require 'iowa/request/Apache'
					Iowa::Request.Type = Iowa::Request::Apache
				elsif request.class.name.index('FCGI') == 0
					require 'iowa/request/FCGI'
					Iowa::Request.Type = Iowa::Request::FCGI
				elsif Object.const_defined?(:Mongrel)
					require 'iowa/request/Mongrel'
					Iowa::Request.Type = Iowa::Request::Mongrel
				elsif Object.const_defined?(:WEBrick)
					require 'iowa/request/WEBrick'
					Iowa::Request.Type = Iowa::Request::WEBrick
				else
					require 'iowa/request/ENV'
					Iowa::Request.Type = Iowa::Request::ENV
				end
			end

			Iowa::Request.Type.new(request)
		end

		def headers
			@headers_in
		end

		def headers=(val)
			@headers_in = val
		end

		def header_only?
			return @header_only
		end

		def [](k)
			@params[k]
		end

		def []=(k,v)
			@params[k] = v
		end

	end

end

#Iowa::Request.Type = Iowa::Request
