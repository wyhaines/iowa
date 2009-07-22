require 'thread'
require 'iowa/AbstractCache'

module Iowa
	module Caches

		# Simple LRU cache for caching pages.  This cache is thread safe.

		class LRUCache < Iowa::AbstractCache

			def initialize(args)
				@cache = {}
				@queue = []
				@ttl_cache = {}
				@finalizers = []
				super(args)
			end

			# Check to see if the cache contains the given key.

			def include?(key)
				@cache.include?(key)
			end

			# Remove a key/value pair from the cache, by key.
		
			def delete(key)
				do_finalization(key,@cache[key])
				@cache.delete key
				@ttl_cache.delete key
			end

			# Return the element identified by the given key.

			def [](key)
				r = nil
				lock_cache do
					if @cache.has_key? key
						r = @cache[key]
						@queue.push @queue.delete(key)
						@ttl_cache[key] = Time.now.to_i
					end
				end
				r
			end
		
			def prune
				obj = @queue.shift
				delete obj
			end

			def attach(key, val)
				already_in_cache = include?(key)
				@cache[key] = val
				@ttl_cache[key] = Time.now.to_i
				if already_in_cache
					@queue.push @queue.delete(key)
				else
					@queue.push key
				end
			end
		
			# Set the element of the cache identified by the given key.  

			def []=(key, val)
				lock_cache do
					if @maxttl
						expiration = Time.now.to_i - @maxttl
						prune while !@queue.empty? && (@ttl_cache[@queue.first].to_i < expiration)
					end
					attach(key, val)
					prune if @queue.length > @max
				end
				@queue
			end

			# Allows one to set the maximum size of the cache queue.  If the queue
			# is currently larger than the size that it is being set to, elements
			# will be expired until the queue is at the maximum size.

			def size=(max)
				lock_cache do
					prune while @queue.length > max
					@max = max
				end
			end
			alias maxsize= size=

			# Return the maximum size of the cache.
			def maxsize
				@max
			end

			# Return the current size of the cache.
			def size
				@queue.length
			end

			# Allows one to set the maximum ttl.  If set to nil, there is no
			# TTL.  Setting the ttl will force a check against the new ttl,
			# expiring anything that it too old.

			def ttl=(newttl)
				@maxttl = newttl ? newttl.to_i : nil
				if @maxttl
					expiration = Time.now.to_i - @maxttl
					prune while !@queue.empty? && (@ttl_cache[@queue.first].to_i < expiration)
				end
			end

			# Returns the maximum TTL.
		
			def ttl
				@maxttl
			end

			# Return a copy of current set of keys to cache elements.
			def queue
				@queue.dup
			end
		
			# Adds a finalization method to the cache that will be called before
			# the object in the cache is expired.	
			def add_finalizer(*args,&block)
				@finalizers.push [block,args]
			end
			
			# Is called when an object in the cache is expired.  Iterates through
			# the defined finalization methods, if any.
			def do_finalization(key,obj)
					begin
						@finalizers.each do |f|
							f[0].call(key,obj,*f[1])
						end
					rescue Exception => e
						puts e, e.backtrace
						raise e
					end
			end

			def lock_cache
				unless @locked
					begin
						@locked = true
						@mutex.synchronize {yield}
					ensure
						@locked = false
					end
				else
					yield
				end
			end
		end
	end
end
