require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/caches/BiLevelCache'
require 'tmpdir'
require 'fileutils'


class TC_BiLevelCache < Test::Unit::TestCase
	def make_tmpdir_path; FileUtils.mkdir("#{Dir::tmpdir}/tc_bilevelcache.#{Time.now.to_i}#{rand}").first; end
	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:bilevelcache, "Iowa::Caches::BiLevelCache")
	end

	def test_creation
		tmpdir = make_tmpdir_path
		assert_nothing_raised("Failed while creating an Iowa::Caches::BiLevelCache object") do
			@cache = Iowa::Caches::BiLevelCache.new({:maxsize => 12}, {:directory => tmpdir, :maxsize => 12})
		end
	ensure
		FileUtils.rm_rf(tmpdir) if tmpdir.to_s != '' and tmpdir.to_s != '/'
	end

	def test_cache_size
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::BiLevelCache.new({:maxsize => 12}, {:directory => tmpdir, :maxsize => 12})
		(1..14).each {|n| @cache[n] = n}
		s = @cache.size
		l2s = @cache.l2.size
		assert_equal(12,s,"The expected size (12) did not match the returned size (#{s}) of the level one cache.")
		assert_equal(2,l2s,"The expected size (2) did not match the returned size (#{l2s}) of the level two cache.")
	ensure
		FileUtils.rm_rf(tmpdir) if tmpdir.to_s != '' and tmpdir.to_s != '/'
	end

	def test_cache_size2
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::BiLevelCache.new({:maxsize => 12}, {:directory => tmpdir, :maxsize => 12})
		(1..14).each {|n| @cache[n] = n}
		@cache.size=3
		s = @cache.size
		@cache.l2.size=3
		l2s = @cache.l2.size
		assert_equal(3,s,"The level one cache size does not appear to to have change as expected; want size of 3, have size of #{s}.")
		assert_equal(3,l2s,"The level two cache size does not appear to to have change as expected; want size of 3, have size of #{l2s}.")
		FileUtils.rm_rf(tmpdir) if tmpdir.to_s != '' and tmpdir.to_s != '/'
	end

	def test_values
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::BiLevelCache.new({:maxsize => 3}, {:directory => tmpdir, :maxsize => 3})
		(1..6).each {|n| @cache[n] = n}
		s = @cache[6]
		l2s = @cache[2]
		assert_equal(6,s,"The value retrieved from the cache (from L1 cache) (#{s}) did not match what was expected (6).")
		assert_equal(2,l2s,"The value retrieved from the cache (from L2 cache) (#{s}) did not match what was expected (2).")
		FileUtils.rm_rf(tmpdir)
	end

	def test_expire1
		tmpdir = make_tmpdir_path
		@cache = Iowa::Caches::BiLevelCache.new({:maxsize => 3}, {:directory => tmpdir, :maxsize => 3})
		(1..8).each {|n| @cache[n] = n}
		assert_equal(false,@cache.include?(1),"Key 1 should have fallen out of the cache.  It did not.")
		assert_equal(true,@cache.include?(3),"Key 3 should not have expired from the cache.  It did.")
		FileUtils.rm_rf(tmpdir)
	end

end
