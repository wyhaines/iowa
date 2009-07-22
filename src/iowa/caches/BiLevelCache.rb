require 'iowa/caches/LRUCache'
require 'iowa/caches/DiskCache'

module Iowa
	module Caches
		class BiLevelCache < Iowa::Caches::LRUCache
			# The bilevel cache takes two sets or arguments.  The first
			# is for itself, and the second is for the L2 cache that it
			# will use.  By default this cache will use an Iowa::Caches::DiskCache,
			# but it can also use any other cache that follows the same API.
			 
			def initialize(l1_args,l2_args)
				oargs = l2_args
				l2_args = Iowa::Hash.new
				l2_args.step_merge!(oargs)
				l2_args.stringify_keys!
				klass = l2_args[Cklass] || Iowa::Caches::DiskCache
				@l2 = klass.new(l2_args)
				super(l1_args)
				add_finalizer {|key,obj| @l2[key] = obj}
			end

			# Return the l2 cache.  Useful for things like cache.l2.size.
			
			def l2
				@l2
			end

			# Check to see if either the L1 or L2 caches contain the given key.

			def include?(key)
				super || @l2.include?(key)
			end

			# Return the element identified by the given key.  If it's not in
			# the L1 cache, the code checks the L2 cache.  If the value is in
			# the L2 cache, it deletes it from the L2 and inserts it back into
			# the L1.

			def [](key)
				r = nil
				@mutex.lock
					if @lookup.has_key? key
						r = super
					elsif @l2.include?(key)
						self[key] = r = @l2[key]
						@l2.delete(key)
					end
				@mutex.unlock
				r
			end
		
			# Check to see if the key is in the L2 cache, and remove it from
			# there if it is, then insert the key/value into the L1 cache.
	
			def []=(key,val)
				@mutex.lock
					@l2.delete(key) if @l2.include?(key)
					super(key,val)
				@mutex.unlock
			end

		end
	end
end
