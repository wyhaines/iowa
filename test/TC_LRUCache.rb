require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/caches/LRUCache'

class TC_LRUCache < Test::Unit::TestCase
	@cache
	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:lrucache,"Iowa::Caches::LRUCache")
	end


	def test_creation
		assert_nothing_raised("Failed while creating an Iowa::Caches::LRUCache object") do
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 12})
		end
	end

	def test_cache_size
		s = nil
		assert_nothing_raised do
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 12})
			(1..14).each {|n| @cache[n] = n}
			s = @cache.size
		end
		assert_equal(12,s,"The expected size (12) did not match the returned size (#{s}).")
	end

	def test_cache_size2
		s = nil
		assert_nothing_raised do
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 12})
			(1..14).each {|n| @cache[n] = n}
			@cache.maxsize=3
			s = @cache.size
		end
		assert_equal(3,s,"The cache size does not appear to to have change as expected; want size of 3, have size of #{s}.")
	end

	def test_values
		s = nil
		assert_nothing_raised do
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
		end
		assert_equal(2,s,"The value retrieved from the cache (#{s}) did not match what was expected (2).")
	end

	def test_expire1
		s = nil
		assert_nothing_raised do
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
			@cache['d'] = 4
			s = true
			s = false if @cache.include? 'a'
		end
		assert_equal(true,s,"Key 'a' should have fallen out of the cache.  It did not.")
	end

	def test_expire2
		s = nil
		assert_nothing_raised do
			@cache = Iowa::Caches::LRUCache.new({:maxsize => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			s = @cache['b']
			@cache['d'] = 4
			s = false
			s = true if @cache.include? 'b'
		end
		assert_equal(true,s,"Key 'b' appears to have fallen out of the cache.  It should not have.")
	end

	def test_expire3
		@cache = nil
		assert_nothing_raised do
			@cache = Iowa::Caches::LRUCache.new({:ttl => 3})
			@cache['a'] = 1
			@cache['b'] = 2
			@cache['c'] = 3
			sleep 2
			@cache.ttl = 1
		end
		assert_equal([],@cache.queue,"There seems to be have been a problem with expiration via TTL timeout.")
	end

	# Method specific tests here.
	
	def test__set
		@cache = Iowa::Caches::LRUCache.new
		assert_equal(1,@cache['a'] = 1,"Failure while testing []=")
	end

	def test__get
		@cache = Iowa::Caches::LRUCache.new
		@cache['a'] = 123
		assert_equal(123,@cache['a'],"Failure while testing []")
	end

	def test__include?
		@cache = Iowa::Caches::LRUCache.new
		@cache['a'] = 1
		@cache['b'] = 2
		@cache['c'] = 3
		assert(@cache.include?('a'),"Failure while testing include?()")
	end

	def test__empty?
		@cache = Iowa::Caches::LRUCache.new
		assert(@cache.empty?,"Failure while testing empty?()")
	end

	def test__delete
		@cache = Iowa::Caches::LRUCache.new
		@cache['a'] = 1
		@cache['b'] = 2
		assert_nothing_raised do
			@cache.delete('a')
		end
		assert_equal(['b'],@cache.queue,"Failure while testing delete()")
	end

	def test__first1
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal(1,@cache.first,"Failure while testing first()")
	end

	def test__first2
		@cache = Iowa::Caches::LRUCache.new
		@cache['a'] = 1
		@cache['b'] = 2
		@cache['c'] = 3
		assert_equal(3,@cache.first,"Failure while testing first()")
	end

	def test__last1
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal(3,@cache.last,"Failure while testing last()")
	end

	def test__last2
		@cache = Iowa::Caches::LRUCache.new
		@cache['a'] = 1
		@cache['b'] = 2
		@cache['c'] = 3
		assert_equal(1,@cache.last,"Failure while testing last()")
	end

	def test__shift
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal(1,@cache.shift,"Failure while testing shift()")
		assert_equal([2,3],@cache.queue,"Failure while testing shift()")
	end

	def test__pop
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal(3,@cache.pop,"Faulure while testing shift()")
		assert_equal([1,2],@cache.queue,"Failure while testing shift()")
	end

	def test__push
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal([1,2,3],@cache.queue,"Failure while testing push()")
	end

	def test__queue
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal([1,2,3],@cache.queue,"Failure while testing queue()")
	end

	def test__to_a
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal([1,2,3],@cache.to_a,"Failure while testing queue()")
	end

	def test__length
		@cache = Iowa::Caches::LRUCache.new
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal(3,@cache.length,"Failure while testing length()")
	end

	def test__each
		@cache = Iowa::Caches::LRUCache.new
		@cache['a'] = 1
		@cache['b'] = 2
		@cache['c'] = 3
		t = ''
		s = 0
		assert_nothing_raised do
			@cache.each do |k,v|
				t << k
				s += v
			end
		end
		assert_equal('cba',t,"Failure while testing each()")
		assert_equal(6,s,"Failure while testing each()")
	end

	def test__maxsize
		@cache = Iowa::Caches::LRUCache.new({:maxsize => 3})
		assert_equal(3,@cache.maxsize,"Failure while testing maxsize()")
		@cache.push 1
		@cache.push 2
		@cache.push 3
		@cache.push 4
		assert_equal(3,@cache.length,"Failure while testing maxsize()")
	end

	def test__maxsize_set
		@cache = Iowa::Caches::LRUCache.new
		assert_nothing_raised do
			@cache.maxsize = 4
		end
		assert_equal(4,@cache.maxsize,"Failure while testing maxsize=()")
		@cache.push 1
		@cache.push 2
		@cache.push 3
		@cache.push 4
		@cache.push 5
		assert_equal(4,@cache.size,"Failure while testing maxsize=()")
		assert_nothing_raised do
			@cache.maxsize = 2
		end
		assert_equal(2,@cache.queue.length,"Failure while testing maxsize=()")
	end

	def test__ttl
		@cache = Iowa::Caches::LRUCache.new(:ttl => 3)
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal(3,@cache.ttl,"Failure while testing ttl()")
	end

	def test__ttl_set
		@cache = Iowa::Caches::LRUCache.new
		assert_nothing_raised do
			@cache.ttl = 10
		end
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal(10,@cache.ttl,"Failure while testing ttl=()")
		sleep 2
		assert_nothing_raised do
			@cache.ttl = 1
		end
		assert_equal(0,@cache.length,"Failure while testing ttl=()")
	end

	def test__add_finalizer
		@cache = Iowa::Caches::LRUCache.new({:maxsize => 2})
		@dest = []
		assert_nothing_raised do
			@cache.add_finalizer(@dest) {|key,obj,dest| dest << key; dest << obj}
		end
		@cache.push 1
		@cache.push 2
		@cache.push 3
		assert_equal([3,3],@dest,"Failure while testing add_finalizer/finalizers.")
	end

end
