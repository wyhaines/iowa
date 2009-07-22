require 'iowa/caches/LRUCache'
require 'iowa/LinkedList'

module Iowa
	module Caches

		# Variation on the LRUCache that lets a class limit the number of instances
		# of itself that can be stored in the cache.
		
		class ClassLimitedCache < Iowa::Caches::LRUCache

			def initialize(args)
				super(args)
				@class_lookup = {}
			end

			def class_node_prune(val_class)
				if val_class.respond_to?(:max_cache_entries)
					unless @class_lookup.has_key?(val_class)
						@class_lookup[val_class] = Iowa::LinkedList.new
					end
					if @class_lookup[val_class].length >= val_class.max_cache_entries
						k = @class_lookup[val_class].pop
						node_purge(@lookup[k])
					end
				end
			end

			def []=(k,v)
				@mutex.lock
				class_node_prune(v.class)
				@class_lookup[v.class][k] = k if @class_lookup.has_key?(v.class)
				super
				@mutex.unlock
			end

			def push(v)
				@mutex.lock
				class_node_prune(v.class)
				@class_lookup[v.class].push v if @class_lookup.has_key?(v.class)
				@mutex.unlock
			end

			def unshift(v)
				@mutex.lock
				class_node_prune(v.class)
				@class_lookup[v.class].unshift v if @class_lookup.has_key?(v.class)
				@mutex.unlock
			end

			def include_class?(klass)
				@class_lookup.has_key? klass
			end

			def queue_for_class(klass)
				@class_lookup[klass].queue
			end

			def node_purge(n)
				vc = n.value.class
				@class_lookup[vc].delete(n.key) if @class_lookup.has_key?(vc)
				super
			end

		end
	end
end
