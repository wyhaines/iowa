require 'test/unit'
require 'external/test_support'
IWATestSupport.cd_to_test_dir(__FILE__)
$:.unshift '../src'
require 'iowa/caches/LRUCache'

# Todo: Rework tests to provide complete coverage.

class TC_LRUCache < Test::Unit::TestCase
	@cache

	def test_creation
		assert_nothing_raised("Failed while creating an Iowa::Caches::LRUCache object") do
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 12})
		end
	end

	def test_cache_size
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 12})
			(1..14).each {|n| @cache[n] = n}
			s = @cache.size
			assert_equal(12,s,"The expected size (12) did not match the returned size (#{s}).")
	end

	def test_cache_size2
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 12})
			(1..14).each {|n| @cache[n] = n}
			@cache.maxsize=3
			s = @cache.size
			assert_equal(3,s,"The cache size does not appear to to have change as expected; want size of 3, have size of #{s}.")
	end

	def test_values
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
			assert_equal(2,s,"The value retrieved from the cache (#{s}) did not match what was expected (2).")
	end

	def test_expire1
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 3})
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
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
			@cache['d'] = 4
			s = false
			s = true if @cache.include? 'b'
			assert_equal(true,s,"Key 'b' appears to have fallen out of the cache.  It should not have.")
	end
end
