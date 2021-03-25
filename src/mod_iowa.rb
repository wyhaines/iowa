require 'iowa/Client'
include Iowa

module Apache
	class Iowa

		URIRegex = Regexp.new('(/*(?:[^/]*/*)*?)(\w+\-\w+\-\w+\.\w+\.[\w\.]+)*$')

		def Iowa.translate_uri(r)
			r.setup_cgi_env
			mapfile = ENV['MAP_FILE'] ? ENV['MAP_FILE'].dup : ''
			mapfile.untaint
			@IowaMapMTime ||= 0
			@IowaMap ||= nil

			if mapfile.to_s != ''
				if @IowaMap and File.stat(mapfile).mtime != @IowaMapMTime
					@IowaMapMTime = File.stat(mapfile)
					@IowaMap = load_map_file(mapfile)
				elsif mapfile.to_s != ''
					@IowaMapMTime = File.stat(mapfile)
					@IowaMap = load_map_file(mapfile)
				end
			end

			if @IowaMap and mapfile.to_s != ''
				upuri = r.unparsed_uri.gsub('\?.*$','') if upuri =~ /\?/
				m = URIRegex.match upuri
				urlRoot = m[1]
				urlRoot.chop! if m[2] unless urlRoot == '/'
				if @IowaMap.has_key? urlRoot
					r.uri = upuri
					r.filename = urlRoot
					return OK
				else
					return DECLINED
				end
			else
				return DECLINED
			end
		end


		def Iowa.handler(r)
			if r.method_number == M_OPTIONS
				r.allowed |= (1 << M_GET)
				r.allowed |= (1 << M_POST)
				return DECLINED
			end
			
			@IowaMapMTime ||= 0
			@IowaMap ||= nil
			r.setup_cgi_env

			mapfile = ENV['MAP_FILE'] ? ENV['MAP_FILE'].dup : ''
			mapfile.untaint
     
			if mapfile.to_s != ''
				if @IowaMap and File.stat(mapfile).mtime != @IowaMapMTime
					@IowaMapMTime = File.stat(mapfile)
					@IowaMap = load_map_file(mapfile)
				elsif mapfile.to_s != ''
					@IowaMapMTime = File.stat(mapfile)
					@IowaMap = load_map_file(mapfile)
				end
			end

			if @IowaMap and mapfile.to_s != ''
				uri = r.uri.to_s
				m = URIRegex.match(uri)
				urlRoot = m[1]
				urlRoot.chop! if m[2] unless urlRoot == '/'
				unless @IowaMap.has_key? urlRoot
					return DECLINED
				end
			end

			client = Iowa::Client.new(ENV['IOWA_SOCKET'])
			client.initiate(r)
			client.receive
			client.print
			return OK
		end

		def Iowa.load_map_file(mapfile)
			map = {}
			begin
				File.open(mapfile,'r') do |fh|
					fh.each do |line|
						next if line =~ /^\s*#/
						line = line.chomp.gsub(/: .*$/,'')
						map[line] = true
					end
				end
			rescue Exception
				map = nil
			end

			return map
		end
	end
end
