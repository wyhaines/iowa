require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/Pool'

class TestPool < Iowa::Pool
	StartSize 3
	MinSize 1
	MaxSize 6
	MaxAge 60
	MonitorInterval 30

	def monitor(obj)
		obj
	end

	def valid?(obj)
		obj
	end

	def newobj
		Hash.new
	end
end

class TC_Pool < Test::Unit::TestCase

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:pool,"Iowa::Pool")
	end

	def test_initialize
		assert_nothing_raised("initialize() on generic Pool failed!") do
			pool = Iowa::Pool.new(:start_size => 3,
														:min_size => 1,
														:max_size => 6,
														:max_age => 60,
														:monitor_interval => 30,
														:monitor => lambda {|o| o},
														:valid => lambda {|o| o},
														:newobj => lambda { Hash.new }
													 )
			assert_equal(3,pool.start_size,"Start size(#{pool.start_size}) is incorrect; it should be 3.")
			assert_equal(1,pool.min_size,"Min size(#{pool.min_size}) is incorrect; it should be 1.")
			assert_equal(6,pool.max_size,"Max size(#{pool.max_size}) is incorrect; it should be 6.")
			assert_equal(60,pool.max_age,"Max age(#{pool.max_age}) is incorrect; it should be 60.")
		end
	end

	def test_init_with_class
		assert_nothing_raised("initialize() on subclass Pool failed!") do
			pool = TestPool.new
			assert_equal(3,pool.start_size,"Start size(#{pool.start_size}) is incorrect; it should be 3.")
			assert_equal(1,pool.min_size,"Min size(#{pool.min_size}) is incorrect; it should be 1.")
			assert_equal(6,pool.max_size,"Max size(#{pool.max_size}) is incorrect; it should be 6.")
			assert_equal(60,pool.max_age,"Max age(#{pool.max_age}) is incorrect; it should be 60.")
		end
	end

	def test_pool_size
		assert_nothing_raised("Failure while testing pool size!") do
			pool = TestPool.new
			assert_equal(3,pool.pool_size,"Pool size(#{pool.pool_size}) seems to be incorrect.  A size of 3 was expected.")
		end
	end

	def test_push_pop
		assert_nothing_raised("Failure while testing push/pop operations!") do
			pool = TestPool.new
			bl1 = pool.length
			ps1 = pool.pool_size
			h1 = pool.pop
			bl2 = pool.length
			ps2 = pool.pool_size
			h2 = pool.pop
			pool.push(h2)
			pool.push(pool.pop)
			bl3 = pool.length
			ps3 = pool.pool_size
			assert_equal(3,bl1,"Array length(#{bl1}) should have been 3.")
			assert_equal(ps1,bl1,"Pool size(#{ps1}) should be equal to array length(#{bl1}).")
			assert_equal(2,bl2,"Array length(#{bl2}) should have been 2.")
			assert_equal(3,ps2,"Pool size(#{ps2}) should have been 3.")
			assert_equal(2,bl3,"Array length(#{bl2}) should have been 2.")
			assert_equal(3,ps3,"Pool size(#{ps2}) should have been 3.")
			h2 = pool.pop
			h3 = pool.pop
			h4 = pool.pop
			assert_equal(0,pool.length,"Array length(#{pool.length}) should be 0.")
			assert_equal(4,pool.pool_size,"Pool size(#{pool.pool_size}) should have expanded to 4.")
		end	
	end

	def test_obtain
		assert_nothing_raised("Failure while testing obtain()!") do
			pool = TestPool.new(:max_size => 4)
			pool.obtain {|x| x[1] = 1}
			pool.obtain do |x|
				pool.obtain {|y| y[:a] = 'a'}
			end
			tpl = []
			tpl << Thread.start do
				pool.obtain do |x1|
					pool.obtain do |x2|
						pool.obtain do |x3|
							pool.obtain do |x4|
								puts "Thread A has all objects in pool (len/size/max: #{pool.length}/#{pool.pool_size}/#{pool.max_size}); sleeping..."
								sleep 10
								puts "Thread A awake and releasing objects."
							end
							puts "Thread A released an object."
						end
						puts "Thread A released an object"
					end
					puts "Thread A released an object."
				end
				puts "Thread A released an object."
			end
			tpl << Thread.start do
				puts "Thread B sleeping for 5 seconds."
				sleep 5
				puts "Thread B requesting an object from the pool.  It should have to wait for an object to be freed."
				pool.obtain do |x5|
					puts "Thread B got an object from the pool."
					sleep 1
					puts "Thread B releasing object from the pool."
				end
			end
			tpl.each {|t| t.join}
		end
	end

	def test_expand
	end


end
