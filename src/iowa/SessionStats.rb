module Iowa

	class SessionStats

		def initialize(page_cache)
			@creation_time = Time.now
			@session_hits = 0
			@rolling_interval = 60
			@rolling_log = []
			@page_cache = page_cache
			@access_time = nil
		end

		def creation_time
			@creation_time
		end

		def hits
			@session_hits
		end

		def uptime
			Time.now.to_i - creation_time.to_i
		end

		def hits_per_second
			@session_hits > 0 ? (hits.to_f / uptime.to_f) : nil
		end

		def pages_maxsize
			@page_cache.maxsize
		end

		def pages_size
			@page_cache.size
		end

		def pages_queue
			@page_cache.queue
		end

		def page(k)
			!@page_cache[k].nil? ? @page_cache[k].dup : nil
		end

		def rolling_interval
			@rolling_interval
		end

		def rolling_interval=(i)
			@rolling_interval = i
		end

		def rolling_hits_total
			@rolling_log.length
		end

		def rolling_hits_per_second
			(@rolling_log.length.to_f / rolling_interval.to_f)
		end

		def access_time
			@access_time
		end

		def hit
			@session_hits += 1
			@access_time = Time.now
			n = @access_time.to_i
			@rolling_log.push n

			while (@rolling_log[0] < (n - @rolling_interval) and @rolling_log.length > 0)
				@rolling_log.shift
			end
		end

	end
end