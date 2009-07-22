require 'thread'
require 'iowa/AbstractCache'
require 'iowa/Lockfile'
require 'digest/sha2'
require 'fileutils'
require 'find'
require 'tmpdir'
require 'iowa/caches/LRUCache'

class Mutex
	def synchronize_unless(cnd)
		unless cnd
			synchronize {yield}
		else
			yield
		end
	end
end

module Iowa

	module Caches

		# DiskStore is an alternative version of DiskCache that eliminates all
		# of the LRU aspects from the code, leaving just the basic persistence
		# structure.

		class DiskStore < Iowa::AbstractCache

			DEFAULT_BUCKET_WIDTH = 2
			DEFAULT_BUCKET_DEPTH = 2

			class NoCacheDir < Exception
				def initialize(*args)
					@bad_dir = args[0]
				end

				def to_s
					"The cache directory (#{@bad_dir}) does not exist."
				end
			end

			class DirNotEmpty < Exception
				def initialize(*args)
					@bad_dir = args[0]
				end

				def to_s
					"The cache directory (#{@bad_dir}) is not empty."
				end
			end

			class DeletedValue
				attr_accessor :val
				def initialize(v)
					@val = v
				end
			end

			def initialize(arg1 = {}, force = nil, width = DEFAULT_BUCKET_WIDTH, depth = DEFAULT_BUCKET_DEPTH, use_lockfile = false)
				@transaction_cache = []
				@transaction_lock = [nil,Iowa::Mutex.new]
				@cache_dir = nil
				if arg1.respond_to?(:keys)
					oargs = arg1
					arg1 = Iowa::Hash.new
					arg1.step_merge!(oargs)
					arg1.stringify_keys!
					if arg1[Cdirectory]
						@cache_dir = arg1[Cdirectory]
					else
						@cache_dir = File.join(Dir::tmpdir,"tmp#{Time.now.to_f}")
						FileUtils.mkdir(@cache_dir)
					end
					set_cachefile_paths
					force = arg1[Cforce] || force
					@bucket_depth = arg1[Cdepth] || depth
					@bucket_width = arg1[Cwidth] || width
					@use_lockfile = arg1[Cuse_lockfile] || use_lockfile
				else
					@cache_dir = arg1
					set_cachefile_paths
					arg1 = {}
					@bucket_depth = depth
					@bucket_width = width
					@use_lockfile = use_lockfile
				end

				super(arg1)
			
				@bucket_depth_array = (0..(@bucket_depth - 1)).to_a
				@locked = false

				unless @use_lockfile
					@mutex = Iowa::Mutex.new
				else
					@lockfile = Iowa::Lockfile.new(File::join(@cache_dir,'cachelock.lck'))
				end
			
				if !FileTest.exist?(@cache_dir)
					if force
						FileUtils.mkdir_p(@cache_dir)
					else
						raise Iowa::Caches::DiskCache::NoCacheDir.new(@cache_dir)
					end
				end
			end

			# Check to see if the cache contains the given key.

			def include?(key)
				if !@bypass_transactions and transaction_cache_include?(key)
					if transaction_cache_get(key).is_a?(DeletedValue)
						false
					else
						true
					end
				else
					FileTest.exist?(datafile_for_key(key))
				end
			end

			# Remove a key/value pair from the cache, by key.
		
			def delete(key)
				lock_cache do
					if !@bypass_transactions and transaction_cache_include?(key)
						tcg = transaction_cache_get(key)
						unless tcg.is_a?(DeletedValue)
							@transaction_cache.last[key] = DeletedValue.new(tcg)
						end
					elsif FileTest.exist?(datafile_for_key(key))
						if @transaction_lock[0] and @transaction_cache.length > 0
							@transaction_cache.last[key] = DeletedValue.new(self[key])
						else
							File::unlink(datafile_for_key(key))
				
							#new_count = getdata(@cache_count,false) - 1
							#putdata(new_count,@cache_count)
						end
					end
				end
			end

			# Return the element identified by the given key.

			def [](key)
				r = nil
				lock_cache do
					if !@bypass_transactions and transaction_cache_include?(key)
						transaction_cache_get(key)
					else
						datafile = datafile_for_key(key)
						if FileTest.exist?(datafile)
							FileUtils::touch(datafile)
							r = getdata(datafile,false)
						end
					end
				end
				r
			end
		
			def prune
				tail = getdata(@cache_tail)
				delete(getdata(File.join(path_for_hash(tail),"#{tail}.key"))) if tail
			end

			def attach(key, val)
				lock_cache do
					already_in_cache = include?(key)

					#putdata((getdata(@cache_count) + 1),@cache_count,false) unless already_in_cache
					# Write the data file.
					putdata(val,datafile_for_key(key))
				end
			end
		
			# Set the element of the cache identified by the given key.  

			def []=(key, val)
				lock_cache do
					if !@bypass_transactions and @transaction_cache.length > 0
						@transaction_cache.last[key] = val
					else
						attach(key, val)
					end
				end
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
				#getdata(@cache_count)
			end

			def ttl=(newttl)
			end
			alias maxttl= ttl=

			def ttl
				getdata(@maxttl)
			end
		
			# Return a copy of current set of keys to cache elements.
			def queue
				r = []
				Find::find(@cache_dir) do |p|
					if p =~ /#{File::SEPARATOR}[^#{File::SEPARATOR}]+.key$/
						r.push getdata(p)
					end
				end
				r
			end
		
			def transaction(&b)
				Thread.critical = true
				if @transaction_lock[0] and @transaction_cache.length > 0
					if Thread.current == @transaction_lock[0]
						Thread.critical = false
						inner_transaction(b)
						return true
					end
				else
					@transaction_lock[0] = Thread.current
				end
				Thread.critical = false
				@transaction_lock[1].synchronize {inner_transaction(b)}
				@transaction_lock[0] = nil
			end

			def commit(final = false)
				Thread.critical = true
				transactions = @transaction_cache.pop
				q = transactions.queue
				(q.length - 1).downto(0) do |x|
					k = q[x]
					v = transactions[k]
					if v.is_a?(DeletedValue)
						@bypass_transactions = true
						self.delete(k)
						@bypass_transactions = false
					else
						@bypass_transactions = true
						self[k] = transactions[k]
						@bypass_transactions = false
					end
				end
				unless final
					@transaction_cache.push Iowa::Caches::LRUCache.new({:maxsize => 4294967296})
				end
				Thread.critical = false
			end

			def rollback
				Thread.critical = true
				@transaction_cache.pop
				@transaction_cache.push Iowa::Caches::LRUCache.new({:maxsize => 4294967296})
				Thread.critical = true
			end

			private

			def inner_transaction(blk)
				@transaction_cache.push Iowa::Caches::LRUCache.new({:maxsize => 4294967296})
				blk.call
				Thread.critical = true
				commit(true)
				Thread.critical = false
			end

			def transaction_cache_include?(key)
				@transaction_cache.each do |tc|
					return true if tc.include? key
				end
				false
			end

			def transaction_cache_get(key)
				(@transaction_cache.length - 1).downto(0) do |x|
					return @transaction_cache[x][key] if @transaction_cache[x].include?(key)
				end
				nil
			end

			def lock_cache
				Thread.critical = true
				transaction_in_progress = (@transaction_lock[0] and @transaction_cache.length > 0) ? true : false
				@transaction_lock[0] = Thread.current unless transaction_in_progress
				Thread.critical = false if transaction_in_progress
				@transaction_lock[1].synchronize_unless(@transaction_lock[0] == Thread.current) do
					Thread.critical = false unless transaction_in_progress
					unless @locked
						begin
							if @use_lockfile
								@lockfile.lock {@locked = true; yield}
							else
								@mutex.synchronize {@locked = true; yield}
							end
						ensure
							@locked = false
						end
					else
						yield
					end
				end
				@transaction_lock[0] = nil unless transaction_in_progress
			end

			def hash_for_key(key)
				Digest::SHA512.hexdigest(Marshal.dump(key))
			end

			def path_for_hash(hash)
				# Take the hash key and break it apart by bucket_depth and bucket_width
				# to return the path to the directory that should contain the
				# cache element.
				File.join(@cache_dir,@bucket_depth_array.collect {|d| hash[(d * @bucket_width),@bucket_width]})
			end
	
			def datafile_for_key(key)
				h = hash_for_key(key)
				File.join(path_for_hash(h),"#{h}.dat")
			end

			def getdata(filename,do_lock = true)
				r = nil
				if do_lock
					lock_cache do
						if FileTest::exist?(filename)
							File.open(filename) {|fh| r = Marshal.load(fh)}
						end
					end
				else
					if FileTest::exist?(filename)
						File.open(filename) {|fh| r = Marshal.load(fh)}
					end
				end
				r
			end

			def getdata_worker(filename)
				if FileTest::exist?(filename)
					File.open(filename) {|fh| Marshal.load(fh)}
				else
					nil
				end
			end

			def putdata(value,filename,do_lock = true)
				if do_lock
					lock_cache do
						putdata_worker(value,filename)
					end
				else
					putdata_worker(value,filename)
				end
			end

			def putdata_worker(value,filename)
				FileUtils.mkdir_p(File::dirname(filename)) unless FileTest.exist?(File::dirname(filename))
				File.open(filename,'w') {|fh| Marshal.dump(value,fh)}
			end

			def set_cachefile_paths
				#@cache_count = File.join(@cache_dir,'cache_count.inf')
			end
		end
	end
end
