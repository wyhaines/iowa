module Iowa

	class ApplicationStats

		def initialize(session_cache)
			@creation_time = Time.now
			@total_hits = 0
			@rolling_interval = 60
			@rolling_log = []
			@session_cache = session_cache
		end

		def creation_time
			@creation_time
		end

		def uptime
			Time.now.to_i - creation_time.to_i
		end

		def hits
			@total_hits
		end

		def hits_per_second
			@total_hits > 0 ? (hits.to_f / uptime.to_f) : nil
		end

		def sessions_maxsize
			@session_cache.maxsize
		end

		def sessions_size
			@session_cache.size
		end

		def sessions_queue
			@session_cache.queue
		end

		def session(k)
			!@session_cache[k].nil? ? @session_cache[k].dup : nil
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
			(rolling_hits_total.to_f / rolling_interval.to_f)
		end

		def hit
			@total_hits += 1
			n = Time.now.to_i
			@rolling_log.push n

			while (@rolling_log[0] < (n - @rolling_interval) and @rolling_log.length > 0)
				@rolling_log.shift
			end
		end

	end
end
