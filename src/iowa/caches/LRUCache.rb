require 'enumerator'
require 'iowa/Mutex'
require 'iowa/Constants'
require 'iowa/Hash'

module Iowa
	module Caches

		#++
		# Iowa::Caches::LRUCache is an LRU cache based on a linked list.
		# It provides efficient random access to elements, like a hash,
		# along with efficient stack or queue-like behaviors -- elements can
		# be pushed, poped, shifted, and unshifted from the cache.
		
		class LRUCache
			include Enumerable

			# * Iowa::Caches::LRUCache.new
			# * Iowa::Caches::LRUCache.new(:maxsize => 20)
			# * Iowa::Caches::LRUCache.new(20)
			# * Iowa::Caches::LRUCache.new(:maxsize => 20, :ttl => 3600)
			# * Iowa::Caches::LRUCache.new(20,3600)
			#
			# If called with no arguments, the cache will default to a max size
			# of 20 elements, with no max time to live (ttl) on the elements.
			#
			# If called using a hash with keyword arguments, the :maxsize is the
			# maximum number of elements to keep in the hash, and :ttl is the 
			# maximum age allowed for elements in the hash.
			#
			# If called with list arguments, the first is the max size, and the
			# second is the TTL.
			
			def initialize(args = {Cmaxsize => 20, Cttl => nil}, ttlarg = nil)
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
					args = {Cmaxsize => args || 20, Cttl => ttlarg}
					retry
				end
				@finalizers = []
				@head = Node.new
				@tail = Node.new
				@lookup = Hash.new
				node_join(@head,@tail)
			end

			
			# Check to see if the given key is in the cache.

			def include?(v)
				@lookup.has_key?(v)
			end
			alias :has_key? :include?

			def [](v)
				@mutex.lock
				if @lookup.has_key?(v)
					n = @lookup[v]
					n.age = Time.now
					node_delete(n)
					node_join(n,@head.next_node)
					node_join(@head,n)
					node_prune
					@mutex.unlock
					n.value
				else
					node_prune
					@mutex.unlock
					nil
				end
			end

			def []=(k,v)
				@mutex.lock
				if @lookup.has_key?(k)
					n = @lookup[k]
					n.value = v
					n.age = Time.now
					node_delete(n)
					node_join(n,@head.next_node)
					node_join(@head,n)
				else
					n = Node.new(k,v,Time.now,@head,@head.next_node)
					node_join(n,@head.next_node)
					node_join(@head,n)
					@lookup[k] = n
				end
				node_prune
				@mutex.unlock
				v
			end

			def empty?
				@lookup.empty?
			end

			def delete(k)
				@mutex.lock
				n = @lookup.delete(k)
				node_purge(n) if n
				node_prune
				@mutex.unlock
				n.value
			end

			def first
				@head.next_node.value
			end

			def last
				@tail.prev_node.value
			end

			def shift
				@mutex.lock
				k = @head.next_node.key
				n = @lookup.delete(k)
				node_delete(n) if n
				node_prune
				@mutex.unlock
				n.value
			end

			def unshift(v)
				@mutex.lock
				if @lookup.has_key?(v)
					n = @lookup[v]
					node_delete(n)
					node_join(n,@head.next_node)
					node_join(@head,n)
				else
					n = Node.new(v,v,Time.now,@head,@head.next_node)
					node_join(n,@head.next_node)
					node_join(@head,n)
					@lookup[v] = n
				end
				node_prune
				@mutex.unlock
				v
			end

			def pop
				@mutex.lock
				k = @tail.prev_node.key
				n = @lookup.delete(k)
				node_delete(n) if n
				node_prune
				@mutex.unlock
				n.value
			end

			def push(v)
				@mutex.lock
				if @lookup.has_key?(v)
					n = @lookup[v]
					node_delete(n)
					node_join(@tail.prev_node,n)
					node_join(n,@tail)
				else
					n = Node.new(v,v,Time.now,@tail.prev_node,@tail)
					node_join(@tail.prev_node,n)
					node_join(n,@tail)
					@lookup[v] = n
				end
				node_prune
				@mutex.unlock
				v
			end

			def queue
				r = []
				n = @head
				while (n = n.next_node) and n != @tail
					r << n.key
				end
				r
			end
	
			def to_a
				r = []
				n = @head
				while (n = n.next_node) and n != @tail
					r << n.value
				end
				r
			end
	
			def length
				@lookup.length
			end
			alias :size :length
	
			def each
				n = @head
				while (n = n.next_node) and n != @tail
					yield(n.key,n.value)
				end
			end

			def maxsize
				@max
			end

			def maxsize=(v)
				@max = v
				node_prune
			end
			alias :size= :maxsize=

			def ttl
				@maxttl
			end

			def ttl=(v)
				@maxttl = v
				node_prune
			end

			# Adds a finalization method to the cache that will be called before
			# the object in the cache is expired.	

			def add_finalizer(*args,&block)
				@finalizers.push [block,args]
			end
			
			private
	
			def node_delete(n)
				node_join(n.prev_node,n.next_node)
			end
	
			def node_purge(n)
				node_join(n.prev_node,n.next_node)
				v = n.value
				k = n.key
				n.value = nil
				n.key = nil
				n.next_node = nil
				n.prev_node = nil
				do_finalization(k,v) if @finalizers
				v
			end

			def node_join(a,b)
				a.next_node = b
				b.prev_node = a
			end

			def node_prune
				node_purge(@lookup.delete(@tail.prev_node.key)) while @lookup.size > @max
				if @maxttl
					expiration_date = Time.now - @maxttl
					while (n = @tail.prev_node) and n != @head and n.age < expiration_date
						node_purge(@lookup.delete(n.key))
					end
				end
			end

			# Is called when an object in the cache is expired.  Iterates through
			# the defined finalization methods, if any.
			def do_finalization(key,obj)
				@finalizers.each do |f|
					f[0].call(key,obj,*f[1])
				end
			end

			class Node
				attr_accessor :key, :value, :age, :prev_node, :next_node

				def initialize(key=nil,value=nil,age=Time.now,prev_node=nil,next_node=nil)
					@key = key
					@value = value
					@age = age
					@prev_node = prev_node
					@next_node = next_node
				end
			end

		end
	end
end
