require 'thread'
require 'iowa/AbstractCache'
require 'iowa/Lockfile'
require 'digest/sha2'
require 'digest/rmd160'
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

		# DiskCache is an LRU cache, but it's data store is not a RAM store.
		# Rather, it serializes its objects to disk.  Generally, if an item
		# is found in an DiskCache, it should be freshened into an in-RAM
		# cache and deleted from the DiskCache.
		#
		# The intent of this cache is that it can, with flat RAM usage,
		# cache, indefinitely, an arbitrary number of elements.
		# So, there needs to be a fast way of representing the cache and
		# and queue to disk.  The TTL cache from the standard LRUCache
		# is not needed because the filesystem will provide that information.
		# The filesystem will also be used to preserve the other data, as well.
		# 
		# The system will implement the cache as an on-disk linked list.
		# By storing the elements in disk buckets based on a very simple
		# hasing of the keys, we'll avoid storing all files into the same
		# directory, and by storing files according to a hashing of the key,
		# we allow efficient lookup of a cache entry.  Each entry will have
		# a data file accompanying it that will encode the key of the
		# element ahead of it and behind it in the cache.  There will also
		# be a special data file that will encode the first and last
		# elements in the list.
		# This will permit rapid access to an individual element, and
		# manipulation of the list without keeping in RAM any permanent
		# state information on the list.
		#
		# Locking can be done with just a mutex, or if used in a
		# multiprocess capacity, locking can be done with a lockfile from
		# Iowa::Lockfile.

		class DiskCache < Iowa::AbstractCache

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

			def initialize(arg1, force = nil, width = DEFAULT_BUCKET_WIDTH, depth = DEFAULT_BUCKET_DEPTH, use_lockfile = false)
				@transaction_cache = []
				@transaction_lock = [nil,Mutex.new]
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
					arg1[Cmaxsize] ||= getdata(@cache_maxsize) if FileTest.exist?(@cache_maxsize)
					arg1[Cttl] ||= getdata(@cache_maxttl) if FileTest.exist?(@cache_maxttl)
					arg1[Cmaxsize] ||= 1000
					@bucket_depth = arg1[Cdepth] || depth
					@bucket_width = arg1[Cwidth] || width
					@use_lockfile = arg1[Cuse_lockfile] || use_lockfile
				else
					@cache_dir = arg1
					set_cachefile_paths
					arg1 = {}
					arg1[Cmaxsize] = getdata(@cache_maxsize) if FileTest.exist?(@cache_maxsize)
					arg1[Cttl] = getdata(@cache_maxttl) if FileTest.exist?(@cache_maxttl)
					@bucket_depth = depth
					@bucket_width = width
					@use_lockfile = use_lockfile
				end

				super(arg1)
			
				@bucket_depth_array = (0..(@bucket_depth - 1)).to_a
				@locked = false

				unless @use_lockfile
					@mutex = Mutex.new
				else
					@lockfile = Iowa::Lockfile.new(File::join(@cache_dir,'cachelock.lck'))
				end
			
				if !FileTest.exist?(@cache_dir)
					if force
						# Force creation of the directory.
						FileUtils.mkdir_p(@cache_dir)
					else
						# Dir doesn't exist, and we aren't forcing, so throw exception.
						raise Iowa::Caches::DiskCache::NoCacheDir.new(@cache_dir)
					end
				end

				# Check to see if directory is empty.
				# If empty, create head and tail files.
				# If not empty, and lacks head and tail files, and create new, empty
				# head and tail files if force is set, or throw exception if unset.
				# If it has head and tail files, cheer and move on.

				lock_cache do
					if Dir[File.join(@cache_dir,'*')].length == 0
						create_head_and_tail_files
					else
						if !(FileTest.exist?(@cache_head) and FileTest.exist?(@cache_tail))
							if force
								create_head_and_tail_files
							else
								raise Iowa::Caches::DiskCache::DirNotEmpty
							end
						end
					end
				end

				# Yay.  There is an existing cache!

				putdata(@max,@cache_maxsize)
				putdata(@maxttl,@cache_maxttl)
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
							# Open the inf file and find this elements head and tail.
				
							links = getdata(linkfile_for_key(key),false)
				
							# Delete the dat file and the inf file.
				
							File::unlink(linkfile_for_key(key))
							File::unlink(datafile_for_key(key))
							File::unlink(keyfile_for_key(key))
				
							# Open the inf file for the head and tail and point them
							# at eachother.
				
							if links[:head]	
								headlink_file = File.join(path_for_hash(links[:head]),"#{links[:head]}.inf")
								headlinks = getdata(headlink_file,false)
								headlinks[:tail] = links[:tail]
								putdata(headlinks,headlink_file)
							else

								# This element is the head of the list.  So, it's tail is the new head.

								putdata(links[:tail],@cache_head)
							end

							if links[:tail]
								taillink_file = File.join(path_for_hash(links[:tail]),"#{links[:tail]}.inf")
								taillinks = getdata(taillink_file,false)
								taillinks[:head] = links[:head]
								putdata(taillinks,taillink_file)
							else

								# This element is the tail of the list.  So, it's head is the new tail.
					
								putdata(links[:head],@cache_tail)
							end

							# Finally, reduce the cache counter.

							new_count = getdata(@cache_count,false) - 1
							putdata(new_count,@cache_count)
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
							#r = getdata(datafile)
							FileUtils::touch(datafile)
							links = getdata(linkfile_for_key(key),false)
	
							if links[:head]	
								headlink_file = File.join(path_for_hash(links[:head]),"#{links[:head]}.inf")
								headlinks = getdata(headlink_file,false)
								headlinks[:tail] = links[:tail]
								putdata(headlinks,headlink_file)
							else
								putdata(links[:tail],@cache_head)
							end
	
							if links[:tail]
								taillink_file = File.join(path_for_hash(links[:tail]),"#{links[:tail]}.inf")
								taillinks = getdata(taillink_file,false)
								taillinks[:head] = links[:head]
								putdata(taillinks,taillink_file)
							else
								putdata(links[:head],@cache_tail)
							end
	
							current_head = getdata(@cache_head,false)
							current_key_hash = hash_for_key(key)
							unless current_key_hash == current_head
								current_tail = getdata(@cache_tail,false)
								putdata({:head => nil, :tail => current_head},linkfile_for_key(key))
								putdata(current_key_hash,@cache_head)
								putdata(current_key_hash,@cache_tail) unless current_tail
								if current_head
									taillink_file = File.join(path_for_hash(current_head),"#{current_head}.inf")
									taillinks = getdata(taillink_file,false)
									taillinks[:head] = current_key_hash
									putdata(taillinks,taillink_file)
								end
							end
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
				# Values are always attached at the head of the list.
				lock_cache do
					already_in_cache = include?(key)

					putdata((getdata(@cache_count) + 1),@cache_count,false) unless already_in_cache
					# Write the data file.
					putdata(val,datafile_for_key(key))
					# Write the key file.
					putdata(key,keyfile_for_key(key)) unless already_in_cache

					if already_in_cache
						links = getdata(linkfile_for_key(key),false)

						if links[:head]	
							headlink_file = File.join(path_for_hash(links[:head]),"#{links[:head]}.inf")
							headlinks = getdata(headlink_file,false)
							headlinks[:tail] = links[:tail]
							putdata(headlinks,headlink_file)
						else
							putdata(links[:tail],@cache_head)
						end

						if links[:tail]
							taillink_file = File.join(path_for_hash(links[:tail]),"#{links[:tail]}.inf")
							taillinks = getdata(taillink_file,false)
							taillinks[:head] = links[:head]
							putdata(taillinks,taillink_file)
						else
							putdata(links[:head],@cache_tail)
						end
					end

					# Get the current head of the list.
					current_head = getdata(@cache_head,false)
					current_key_hash = hash_for_key(key)
					unless current_key_hash == current_head
						# Get the current tail of the list.
						current_tail = getdata(@cache_tail,false)
						# Write the link file for the new head.
						putdata({:head => nil, :tail => current_head},linkfile_for_key(key))
						# Change the cache_head so it points to the new head.
						putdata(current_key_hash,@cache_head)
						# If the tail wasn't pointint to anything, the list was empty.
						# Point it to this record.
						putdata(current_key_hash,@cache_tail) unless current_tail
						# Change the old head so that it points to the new element as its head.
						if current_head
							taillink_file = File.join(path_for_hash(current_head),"#{current_head}.inf")
							taillinks = getdata(taillink_file,false)
							taillinks[:head] = current_key_hash
							putdata(taillinks,taillink_file)
						end
					end
				end
			end
		
			# Set the element of the cache identified by the given key.  

			def []=(key, val)
				lock_cache do
					if !@bypass_transactions and @transaction_cache.length > 0
						@transaction_cache.last[key] = val
					else
						attach(key, val)
						mxsz = getdata(@cache_maxsize,false)
						if mxsz > 0
							prune while getdata(@cache_count,false) > mxsz
						end
						maxttl = getdata(@cache_maxttl,false)
						if maxttl
							expiration = Time.now.to_i - maxttl
							prune while (getdata(@cache_count,false) > 0) && (File::stat(datafile_for_key(getdata(@cache_tail,false))).mtime.to_i < expiration)
						end
					end
				end
			end

			# Allows one to set the maximum size of the cache queue.  If the queue
			# is currently larger than the size that it is being set to, elements
			# will be expired until the queue is at the maximum size.

			def size=(max)
				lock_cache do
					prune while getdata(@cache_count,false) > max
					putdata(max,@cache_maxsize)
				end
			end
			alias maxsize= size=

			# Return the maximum size of the cache.
			def maxsize
				getdata(@cache_maxsize)
			end

			# Return the current size of the cache.
			def size
				getdata(@cache_count)
			end

			def ttl=(newttl)
				newttl = newttl ? newttl.to_i : nil
				if @maxttl
					lock_cache do
						expiration = Time.now.to_i - newttl
						prune while (getdata(@cache_count,false) > 0) && (File::stat(datafile_for_key(getdata(@cache_tail,false))).mtime.to_i < expiration)
					end
				end
				putdata(newttl,@cache_maxttl)
			end
			alias maxttl= ttl=

			def ttl
				getdata(@maxttl)
			end
		
			# Return a copy of current set of keys to cache elements.
			def queue
				r = []
				#Find::find(@cache_dir) do |p|
				#	if p =~ /#{File::SEPARATOR}[^#{File::SEPARATOR}]+.key$/
				#		r.push getdata(p)
				#	end
				#end
				n = getdata(@cache_head)
				loop do
					links = getdata(File.join(path_for_hash(n),"#{n}.inf"))
					r.push getdata(File.join(path_for_hash(n),"#{n}.key"))
					break if links[:tail].nil?
					n = links[:tail]
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

			def create_head_and_tail_files
				putdata(nil,@cache_head)
				putdata(nil,@cache_tail)
				putdata(0,@cache_count)
				putdata(@max,@cache_maxsize)
				putdata(@maxttl,@cache_maxttl)
			end

			def hash_for_key(key)
				k = Marshal.dump(key)
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

			def linkfile_for_key(key)
				h = hash_for_key(key)
				File.join(path_for_hash(h),"#{h}.inf")
			end

			def keyfile_for_key(key)
				h = hash_for_key(key)
				File.join(path_for_hash(h),"#{h}.key")
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
				@cache_head = File.join(@cache_dir,'cache_head.inf')
				@cache_tail = File.join(@cache_dir,'cache_tail.inf')
				@cache_count = File.join(@cache_dir,'cache_count.inf')
				@cache_maxsize = File.join(@cache_dir,'cache_maxsize.inf')
				@cache_maxttl = File.join(@cache_dir,'cache_maxttl.inf')
			end
		end
	end
end
