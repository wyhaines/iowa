require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/caches/ClassLimitedCache'

class FooClass
	def self.max_cache_entries; 2; end
end

class BarClass
	def self.max_cache_entries; 1; end
end

class TC_ClassLimitedCache < Test::Unit::TestCase
	@cache

	@@testdir = IWATestSupport.test_dir(__FILE__)

	def setup
		IWATestSupport.announce(:classlimitedcache,"Iowa::Caches::ClassLimitedCache")
		Dir.chdir(@@testdir)
	end

	def test_creation
		assert_nothing_raised("Failed while creating an Iowa::Caches::ClassLimitedCache object") do
			@cache = Iowa::Caches::ClassLimitedCache.new({:maxsize => 12})
		end
	end

	def test_cache_size
			@cache = Iowa::Caches::ClassLimitedCache.new({:maxsize => 12})
			(1..14).each {|n| @cache[n] = n}
			s = @cache.size
			assert_equal(12,s,"The expected size (12) did not match the returned size (#{s}).")
	end

	def test_cache_size2
			@cache = Iowa::Caches::ClassLimitedCache.new({:maxsize => 12})
			(1..14).each {|n| @cache[n] = n}
			@cache.size=3
			s = @cache.size
			assert_equal(3,s,"The cache size does not appear to to have change as expected; want size of 3, have size of #{s}.")
	end

	def test_values
			@cache = Iowa::Caches::ClassLimitedCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
			assert_equal(2,s,"The value retrieved from the cache (#{s}) did not match what was expected (2).")
	end

	def test_expire1
			@cache = Iowa::Caches::ClassLimitedCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
			@cache['d'] = 4
			s = true
			s = false if @cache.include? 'a'
			assert_equal(true,s,"Key 'a' should have fallen out of the cache.  It did not.")
	end

	def test_expire2
			@cache = Iowa::Caches::ClassLimitedCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
			@cache['d'] = 4
			s = false
			s = true if @cache.include? 'b'
			assert_equal(true,s,"Key 'b' appears to have fallen out of the cache.  It should not have.")
	end

	def test_class_limits
		@cache = Iowa::Caches::ClassLimitedCache.new({:maxsize => 10})
		@cache[:a] = FooClass.new
		@cache[:b] = FooClass.new
		@cache[:c] = FooClass.new
		@cache[:d] = BarClass.new
		@cache[:e] = BarClass.new
		assert_equal([:e, :c, :b],@cache.queue,"Queue for the cache appears to be incorrect.")
		assert_equal([:c, :b],@cache.queue_for_class(FooClass),"Queue for class FooClass appears to be incorrect.")
		assert_equal([:e],@cache.queue_for_class(BarClass),"Queue for class BarClass appears to be incorrect.")
	end
end
