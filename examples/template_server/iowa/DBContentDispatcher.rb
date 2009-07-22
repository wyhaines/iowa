require 'iowa/caches/LRUCache'

module Iowa
	module Dispatchers
		class DBContentDispatcher

			attr_accessor :dbpool

			class NoMapFile < Exception; end

			def initialize(args)
				@mapfileMTime = 0
				@dbLMTime = {:pub => 0, :priv => 0}
				@next_check = 0
				@urlMap = {:pub => {}, :priv => {}}
				@dbMap = {:pub => {}, :priv => {}}
				@dbpool = {}
				@mapfile = 'mapfile.map'
				raise(NoMapFile, "The mapfile (@mapfile) does not appear to exist.") unless FileTest.exist?(@mapfile)
				@min_recheck_interval = args[:min_recheck_interval] ? args[:min_recheck_interval] : 30
			end

			def read_mapfile
				if File.stat(@mapfile).mtime != @mapfileMTime
					File.open(@mapfile) {|mf| @urlMap = YAML::load(mf)}
					File.stat(@mapfile).mtime
				end
			end

			def read_db
				[:pub,:priv].each {|s| @dbpool[s].obtain {|ksdbh| poll_db(ksdbh,s)}}
			end

			def poll_db(ksdbh,side)
				lmtime = nil
				ksdbh.select_all('select max(last_modified) from product_urls') {|row| lmtime = row[0]}
				if lmtime and lmtime.to_time.to_i > @dbLMTime[side]
					@dbLMTime[side] = lmtime.to_time.to_i
					@dbMap[side] = {}
					ksdbh.select(:ProductUrls).each {|pu| @dbMap[side][pu.url] = pu.product_idx}
				end
			end

			# Returns true if the dispatcher is willing to handle this request.
	
#			def handleRequest?(path)
#				if @next_check < Time.now.to_i
#					@next_check = Time.now.to_i + @min_recheck_interval
#					read_mapfile
#					read_db
#				end
#
#				if !Iowa.app.policy.getIDs(path)[1].nil?
#					true
#				elsif @urlMap[path] or @dbMap[path]
#					true
#				else
#					false
#				end
#			end
		
			# Dispatches the request.
		 
			def dispatch(session,context,specific_page = nil)
				unless specific_page
					request = context.request
					if @next_check < Time.now.to_i
						@next_check = Time.now.to_i + @min_recheck_interval
						read_mapfile
						read_db
					end

					side = :pub
					if context.cookies.has_key?(::Cdirexion_id)
						direxion_id = context.cookies[::Cdirexion_id]
						if direxion_id.nil?
							request.uri = '/logout.html'
						else
							if Iowa.app.direxion_id_cache.include?(direxion_id)
								side = :priv
							else
								@dbpool[:priv].obtain do |ksdbh|
									auth = ksdbh.select(:Authorization) {|a| a.idx == direxion_id}.first
									if auth
										side = :priv
										Iowa.app.direxion_id_cache[direxion_id] = true
									end
								end
							end
							if side == :pub
								# expire a bad cookie
							end
						end

					end

					if @urlMap[side][request.uri]
						context[:side] = side
						specific_page = @urlMap[side][request.uri]
					elsif @dbMap[side][request.uri]
						context[:product_id] = @dbMap[side][request.uri]
						context[:side] = side
						specific_page = 'DBContentPage'
					end
				end
				Logger['iowa_log'].info "Dispatching to #{specific_page}"
				session.handleRequest(context,specific_page)
			end

		end
	end
end
