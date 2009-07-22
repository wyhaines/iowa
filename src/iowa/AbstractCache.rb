# This file illustrates the methods that any cache implementation
# must expose in order for IOWA to use it.  An application will
# default to using the LRUCache unless told otherwise.

require 'thread'
require 'iowa/Constants'
require 'iowa/Hash'

module Iowa

	# Caches must be thread safe.

	class AbstractCache

		# Initialize the empty cache.  The initialization must accept a hash as
		# an argument, and must accept, at a minimum, the following key/value
		# pairs in the hash as arguments:
		#   :maxsize -- the maximum number of elements to cache.
		#   :maxttl -- the maximum age, in seconds, of an element in the cache.
		#
		# Every argument to the cache must have an acceptable default value.

		def initialize(args = {Cmaxsize => 20, Cttl => nil})
			if args.kind_of? ::Hash
				oargs = args
				args = Iowa::Hash.new
				args.step_merge!(oargs)
			end
			args.stringify_keys! if args.respond_to? :stringify_keys!
			begin
				@max = args[Cmaxsize] || 20
				@maxttl = args[Cttl]
				@mutex = Iowa::Mutex.new
			rescue Exception
				args = {Cmaxsize => 20, Cttl => nil}
				retry
			end
		end

		# Check to see if the cache contains the given key.

		def include?(key)
		end

		# Remove a key/value pair from the cache, by key.
		
		def delete(key)
		end

		# Return the element identified by the given key.

		def [](key)
		end
		
		# Set the element of the cache identified by the given key.  

		def []=(key, val)
		end

		# Allows one to set the maximum size of the cache queue.  If the queue
		# is currently larger than the size that it is being set to, elements
		# will be expired until the queue is at the maximum size.

		def size=(max)
		end
		alias maxsize= size=

		# Return the maximum size of the cache.

		def maxsize
		end

		# Return the current size of the cache.

		def size
		end

		# Return a copy of current set of keys to cache elements.

		def queue
		end
		
		# Adds a finalization method to the cache that will be called before
		# the object in the cache is expired.	

		def add_finalizer(*args,&block)
		end
		
		# Is called when an object in the cache is expired.  Iterates through
		# the defined finalization methods, if any.

		def do_finalization(key,obj)
		end

	end
end
