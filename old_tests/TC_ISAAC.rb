require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/ISAAC'

class TC_ISAAC < Test::Unit::TestCase
  @generator = nil

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:isaac,"Crypt::ISAAC")
		assert_nothing_raised("Failed to create a Crypt::ISAAC object.") do
			@generator = Crypt::ISAAC.new
		end
	end

	def testKind
		assert_kind_of(Crypt::ISAAC,@generator,"The created object is not a Crypt::ISAAC or subclass thereof.") 
	end

	def testInteger
		assert_nothing_raised("Failed while generating an integer random number.") do
			mynum = @generator.rand(1000000)
			assert_kind_of(Integer,mynum,"The generator failed to return an integer number in response to @generator.rand(1000000).")
			assert((mynum >= 0),"The generator returned a number that is less than 0 (#{mynum}).")
			assert((mynum < 1000000),"The generator returned a number that is greater than or equal to 1000000 (#{mynum}).")
		end
	end

	def testFloat
		assert_nothing_raised("Failed while generating a floating point random number.") do
			mynum = @generator.rand()
			assert_kind_of(Float,mynum,"The generator failed to return a floating point number in response to @generator.rand().")
			assert((mynum >= 0),"The generator returned a number that is less than 0 (#{mynum}).")
			assert((mynum < 1),"The generator returned a number that is greater than or equal to 1 (#{mynum}).")
		end
	end

	def testIterations
		puts
		count = 0
		assert_nothing_raised("Failed on iteration #{count} while trying to generate 100000 random numbers.") do
			100000.times do
				count += 1
				puts '.' if (count % 10000) == 0
				# toggle between integer and floating point numbers.
				num = count % 2 ? @generator.rand(65536) : @generator.rand()
			end
		end
	end
end
