require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/String'

class TC_String < Test::Unit::TestCase

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:string, "Iowa::String")
		assert_nothing_raised("setup failed") do
			@iwa_string = Iowa::String.new("basic string")
		end
	end

	def test_conversions
		assert_equal('basic string',@iwa_string,"Unaltered Test: Test string(#{@iwa_string}) was not what was expected (basic string).")
		assert_equal('basicString',@iwa_string.camelCase,"camelCase Test: Test string(#{@iwa_string.camelCase}) was not what was expected (basicString).")
		assert_equal('BasicString',@iwa_string.constantCase,"constantCase Test: Test string(#{@iwa_string.constantCase}) was not what was expected (BasicString).")
		assert_equal('Basic string',@iwa_string.humanCase,"humanCase Test: Test string(#{@iwa_string.humanCase}) was not what was expected (Basic string).")
		assert_equal('basic_string',@iwa_string.snakeCase,"snakeCase Test: Test string(#{@iwa_string.snakeCase}) was not what was expected (basic_string).")
	end
end
