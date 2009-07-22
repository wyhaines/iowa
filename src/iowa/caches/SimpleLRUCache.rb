# This cache is based off of the LRUCache found in Facets
# (http://facets.rubyforg.org) version 1.7.30, which was
# contributed by George Moscovitis.

module Iowa
	module Caches
		class SimpleLRUCache < Hash

			# Mix this in your class to make LRU-managable.

			module Item
				attr_accessor :lru_key, :lru_prev, :lru_next
			end

			class Sentinel; include Item; end

			attr_accessor :max_items
			attr_reader :head, :tail

			def initialize(args = {Cmaxsize => 20, Cttl => nil})
				@finalizers = []
		    lru_clear()
				if args.kind_of? ::Hash
					oargs = args
					args = ::Iowa::Hash.new
					args.step_merge!(oargs)
				end
				args.stringify_keys! if args.respond_to? :stringify_keys!
				begin
					@max_items = args[Cmaxsize] || 20
					@ttl = args[Cttl]
					@timer = nil
  		  	lru_clear()
				rescue Exception
					args = {Cmaxsize => args || 20, Cttl => nil}
					retry
				end
		  end

			def [](key)
				if item = super
					lru_touch(item)
				end
			end

			def []=(key, item)
				item = super
				item.lru_key = key
				lru_insert(item)
			end

			def delete(key)
				lru_delete(item) if item = super
			end

			def clear
				super
				lru_clear()
			end

			def first
				@head.lru_next
			end

			def last
				@tail.lru_prev
			end
			alias_method :lru, :last

			def add_finalizer(*args,&block)
				@finalizers.push [block,args]
			end

			private

			def lru_delete(item)
				lru_join(item.lru_prev, item.lru_next)
				item
			end

			def lru_join(x, y)
				x.lru_next = y
				y.lru_prev = x
				y
			end

			def lru_append(parent, child)
				lru_join(child, parent.lru_next)
				lru_join(parent, child)
			end

			def lru_insert(item)
				lru_append(@head, item)
				delete(last.lru_key) if size() > @max_items
			end

			def lru_touch(item)
				lru_append(@head, lru_delete(item))
			end

			def lru_clear
				@head = Sentinel.new
				@tail = Sentinel.new
				lru_join(@head, @tail)
			end

			def do_finalization(key,obj)
				@finalizers.each {|f| f[0].call(key,obj,*f[1])}
			end
		end
	end
end
