require 'enumerator'

module Iowa

	# This is a simple linked list implementation with efficient random
	# access of data elements.  It was inspired by George Moscovitis'
	# LRUCache implementation found in Facets 1.7.30, but unlike the
	# linked list in that cache, this one does not require the use of a
	# mixin on any class to be stored.  The linked list provides the
	# push, pop, shift, unshift, first, last, delete and length methods
	# which work just like their namesakes in the Array class, but it
	# also supports setting and retrieving values by key, just like a
	# hash.

	class LinkedList
		include Enumerable

		# Represents a single node of the linked list.
		
		class Node
			attr_accessor :key, :value, :prev_node, :next_node

			def initialize(key=nil,value=nil,prev_node=nil,next_node=nil)
				@key = key
				@value = value
				@prev_node = prev_node
				@next_node = next_node
			end
		end

		# Create a new LinkedList.

		def initialize
			@head = Node.new
			@tail = Node.new
			@lookup = Hash.new
			node_join(@head,@tail)
		end

		# Retrieves the node referenced by the key value provided.
		def [](k)
			@lookup[k].value
		end

		def []=(k,v)
			if @lookup.has_key?(k)
				@lookup[k].value = v
			else
				n = Node.new(k,v,@head,@head.next_node)
				node_join(n,@head.next_node)
				node_join(@head,n)
				@lookup[k] = n
			end
			v
		end

		def has_key?(k)
			@lookup.has_key?(k)
		end
		alias :include? :has_key?

		def empty?
			@lookup.empty?
		end

		def delete(k)
			n = @lookup.delete(k)
			v = n ? node_purge(n) : nil
			v
		end

		def first
			@head.next_node.value
		end

		def last
			@tail.prev_node.value
		end

		def shift
			k = @head.next_node.key
			n = @lookup.delete(k)
			node_delete(n) if n
		end

		def unshift(v)
			if @lookup.has_key?(v)
				n = @lookup[v]
				node_delete(n)
				node_join(n,@head.next_node)
				node_join(@head,n)
			else
				n = Node.new(v,v,@head,@head.next_node)
				node_join(n,@head.next_node)
				node_join(@head,n)
				@lookup[v] = n
			end
			v
		end

		def pop
			k = @tail.prev_node.key
			n = @lookup.delete(k)
			node_delete(n) if n
		end

		def push(v)
			if @lookup.has_key?(v)
				n = @lookup[v]
				node_delete(n)
				node_join(@tail.prev_node,n)
				node_join(n,@tail)
			else
				n = Node.new(v,v,@tail.prev_node,@tail)
				node_join(@tail.prev_node,n)
				node_join(n,@tail)
				@lookup[v] = n
			end
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
		alias :keys :queue

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

		def each
			n = @head
			while (n = n.next_node) and n != @tail
				yield(n.key,n.value)
			end
		end

		private

		def node_delete(n)
			node_join(n.prev_node,n.next_node)
			v = n.value
		end

		def node_purge(n)
			node_join(n.prev_node,n.next_node)
			v = n.value
			n.value = nil
			n.key = nil
			n.next_node = nil
			n.prev_node = nil
			v
		end

		def node_join(a,b)
			a.next_node = b
			b.prev_node = a
		end

	end
end
