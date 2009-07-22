require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/caches/DiskCache'
require 'iowa/caches/DiskStore'
require 'tmpdir'
require 'fileutils'
require 'benchmark'
require 'pstore'

TMPDIR = Dir::tmpdir

class TC_DiskCache < Test::Unit::TestCase
	def make_tmpdir_path; FileUtils.mkdir("#{TMPDIR}/tc_diskcache.#{Time.now.to_i}#{rand}").first; end
	def make_shm_tmpdir_path; FileUtils.mkdir("/dev/shm/tc_diskcache.#{Time.now.to_i}#{rand}").first; end
	@@testdir = IWATestSupport.test_dir(__FILE__)

	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:diskcache,"Iowa::Caches::DiskCache / Iowa::Caches::DiskStore")
	end

	def test_creation
		tmpdir = make_tmpdir_path
		assert_nothing_raised("Failed while creating an Iowa::Caches::DiskCache object") do
			@cache = Iowa::Caches::DiskCache.new({:directory => tmpdir, :maxsize => 12})
		end
		FileUtils.rm_rf(tmpdir)
	end

	def test_cache_size
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::DiskCache.new({:directory => tmpdir, :maxsize => 12})
		(1..14).each {|n| @cache[n] = n}
		s = @cache.size
		assert_equal(12,s,"The expected size (12) did not match the returned size (#{s}).")
		FileUtils.rm_rf(tmpdir)
	end

	def test_cache_size2
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::DiskCache.new({:directory => tmpdir, :maxsize => 12})
		(1..14).each {|n| @cache[n] = n}
		@cache.size=3
		s = @cache.size
		assert_equal(3,s,"The cache size does not appear to to have change as expected; want size of 3, have size of #{s}.")
		FileUtils.rm_rf(tmpdir)
	end

	def test_values
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::DiskCache.new({:directory => tmpdir, :maxsize => 3})
		@cache['a'] = 1
		@cache['b'] = 2
		@cache['c'] = 3
		s = @cache['b']
		assert_equal(2,s,"The value retrieved from the cache (#{s}) did not match what was expected (2).")
		FileUtils.rm_rf(tmpdir)
	end

	def test_expire1
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::DiskCache.new({:directory => tmpdir, :maxsize => 3})
		@cache['a'] = 1
		@cache['b'] = 2
		@cache['c'] = 3
		s = @cache['b']
		@cache['d'] = 4
		s = true
		s = false if @cache.include? 'a'
		assert_equal(true,s,"Key 'a' should have fallen out of the cache.  It did not.")
		FileUtils.rm_rf(tmpdir)
	end

	def test_expire2
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::DiskCache.new({:directory => tmpdir, :maxsize => 3})
		@cache['a'] = 1
		@cache['b'] = 2
		@cache['c'] = 3
		s = @cache['b']
		@cache['d'] = 4
		s = false
		s = true if @cache.include? 'b'
		assert_equal(true,s,"Key 'b' appears to have fallen out of the cache.  It should not have.")
		FileUtils.rm_rf(tmpdir)
	end

	def test_transactions
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::DiskCache.new({:directory => tmpdir, :maxsize => 20})
		assert_nothing_raised("Something blew up when trying to test transactions.") do
			@cache[:a] = 1
			@cache[:b] = 2
			@cache.transaction do
				@cache[:c] = 3
			end
			assert_equal(3,@cache[:c],"Transaction failed.")
			@cache.transaction do
				@cache[:d] = 4
				@cache.commit
				@cache[:e] = 5
			end
			assert_equal(4,@cache[:d],"Transaction failed.")
			assert_equal(5,@cache[:e],"Transaction failed.")
			@cache.transaction do
				@cache[:f] = 6
				@cache.rollback
			end
			assert(!@cache.include?(:f),"Transaction rollback failed.")
			@cache.transaction do
				@cache[:f] = 6
				@cache.rollback
				@cache[:g] = 6
			end
			assert(!@cache.include?(:f),"Transaction rollback failed.")
			assert_equal(6,@cache[:g],"Transaction failed.")
			@cache.transaction do
				@cache[:h] = 7
				@cache.transaction do
					@cache[:i] = 8
					@cache.transaction do
						@cache[:j] = 9
						@cache.rollback
					end
					@cache.transaction do
						@cache[:k] = 9
					end
					@cache.rollback
				end
			end
			assert(!@cache.include?(:j),"Nested transaction rollback(:j) failed.")
			assert(!@cache.include?(:i),"Nexted transaction rollback(:i) failed.")
			assert_equal(7,@cache[:h],"Transaction failed.")
			assert_equal(9,@cache[:k],"Transaction failed.")
		end
	end
	
	def test_speed
		n = 2000
		test_dirs = []
		test_dirs << ["In-Memory (/dev/shm) Test", make_shm_tmpdir_path] if FileTest.exist?('/dev/shm') and FileTest.writable?('/dev/shm')
		test_dirs << ["On Disk Test (performance directly related to disk i/o performance)", make_tmpdir_path]
		assert_nothing_raised("Something blew up during the DiskCache stress test.") do
			test_dirs.each do |td|
				puts "\n#{td[0]}"
				cache = Iowa::Caches::DiskCache.new({:directory => td[1], :maxsize => 4294967296})
				Benchmark.benchmark do |bm|
					flush_disk
					puts "Writing #{n} records to disk cache:"
					bm.report('dc write') do
						n.times {|x| cache[x] = x}
					end
					flush_disk
					puts "Updating #{n} records in disk cache:"
					bm.report('dc update') do
						n.times {|x| cache[x] = x * 2}
					end
					flush_disk
					puts "Reading #{n} records from disk cache:"
					bm.report('dc read') do
						(n).times {|x| cache[x]}
					end
					flush_disk
					puts "Deleting #{n} records from disk cache:"
					bm.report('dc delete') do
						n.times {|x| cache.delete(x)}
					end
					flush_disk
				end
				FileUtils.rm_rf(td[1])
			end
		end

		flush_disk
		puts "\n\nNow Running speed comparison of DiskStore"
		test_dirs = []
		test_dirs << ["In-Memory (/dev/shm) Test", make_shm_tmpdir_path] if FileTest.exist?('/dev/shm') and FileTest.writable?('/dev/shm')
		test_dirs << ["On Disk Test (performance directly related to disk i/o performance)", make_tmpdir_path]
		assert_nothing_raised("Something blew up during the DiskCache stress test.") do
			test_dirs.each do |td|
				puts "\n#{td[0]}"
				cache = Iowa::Caches::DiskStore.new({:directory => td[1]})
				Benchmark.benchmark do |bm|
					flush_disk
					puts "Writing #{n} records to disk cache:"
					bm.report('dc write') do
						n.times {|x| cache[x] = x}
					end
					flush_disk
					puts "Updating #{n} records in disk cache:"
					bm.report('dc update') do
						n.times {|x| cache[x] = x * 2}
					end
					flush_disk
					puts "Reading #{n} records from disk cache:"
					bm.report('dc read') do
						(n).times {|x| cache[x]}
					end
					flush_disk
					puts "Deleting #{n} records from disk cache:"
					bm.report('dc delete') do
						n.times {|x| cache.delete(x)}
					end
					flush_disk
				end
				FileUtils.rm_rf(td[1])
			end
		end
	end

	def flush_disk
		if FileTest.exist?('/bin/sync')
			system('/bin/sync')
		end
	end

end
