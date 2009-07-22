require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/KeyValueCoding'

class TC_KeyValueCoding < Test::Unit::TestCase

	Obj = Struct.new('Obj', :foo, :bar)

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:keyvaluecoding,"Iowa::KeyValueCoding")
		@obj = Obj.new(Obj.new(Obj.new('a')),7)
	end

	def test_takeValueForKey
		assert_nothing_raised("Failed while calling takeValueForKey") do
			@obj.takeValueForKey(7,"bar")
		end
		assert_equal(@obj.valueForKey("bar"),7,"Failed while calling valueForKey")
	end

	def test_valueForKeyPath
		assert_nothing_raised("Failed while calling valueForKeyPath") do
			@obj.takeValueForKeyPath("a","foo.foo")
		end
		assert_equal(@obj.valueForKeyPath("foo.foo"),"a","Failed while calling valueForKeyPath")
	end

	def test_existsKeyPath?
		assert(@obj.existsKeyPath?('foo.foo.bar'),"existsKeyPath? failed.")
	end

end
