require 'net/http'
require 'iowa/caches/LRUCache'

module Iowa
	class Webcache

		unless Object.const_defined?(:WCLCacheItem)
			WCLCacheItem = Struct.new('WCLCacheItem', :expires, :etag, :last_modified)
		end

		def initialize(cache_size = 100)
			@cache = Iowa::LRUCache.new(cache_size)
		end

		def new_cache_item(query)
			item = WCLCacheItem.new
			item.etag = query['etag']
			if query['expires']
				begin
					item.expires = Date.parse(query['expires']).to_time
				rescue Exception
				end
			else
				# Expire 30 seconds from now if there is no expiration.
				item.expires = Time.now + 30
			end

			if query['last_modified']
				begin
					item.last_modified = Date.parse(query['last_modified']).to_time
				rescue Exception
				end
			end
			item
		end

		def get_url_head(url)
			tries = 0
			response = {}
			if /^http/.match(url)
				m = /^http[s]*:\/\/([^\/]*)(.*)/.match(url)
				site = m[1]
				site, port = site.split(':')
				port ||= 80
				path = m[2]
				begin
					http = Net::HTTP.new(site,port)
					http.open_timeout = 3
					http.start {|h| response = h.head(path)}
				rescue Exception
					tries += 1
					retry if tries < 1
				end
			end
			response
		end

		def get_url(url)
			tries = 0
			response = {}
			if /^http/.match(url)
				m = /^http[s]*:\/\/([^\/]*)(.*)/.match(url)
				site = m[1]
				site, port = site.split(':')
				port ||= 80
				path = m[2]
				begin
					http = Net::HTTP.new(site,port)
					http.open_timeout = 3
					http.start {|h| response = h.get(path)}
				rescue Exception
					tries += 1
					retry if tries < 1
				end
			end
			response.kind_of?(Array) ? response[1] : response.respond_to?(:body) ? response.body : ''
		end

		def set_cache(url)
			@cache[url] = new_cache_item(get_url_head(url))
		end

		def [](url)
			if item = @cache[url]
				# Check

				# If expires < now or no expires, check.
				if (item.expires.nil?) or (item.expires && item.expires < Time.now)
					query = new_cache_item(get_url_head(url))
					
					# If there is an etag, compare.
					if query.etag
						if item.etag == query.etag
							nil
						else
							@cache[url] = query
							get_url(url)
						end
					elsif query.last_modified
						if query.last_modified > item.last_modified
							@cache[url] = query
							get_url(url)
						else
							nil
						end
					else
						@cache[url] = new_cache_item(query)
						get_url(url)
					end
				else
					nil
				end
			else
				# Initial Fetch
				set_cache(url)

				# Since it's the initial fetch, it is new and must be loaded.
				get_url(url)
			end
		end
	end
end
