require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa'

class MyApp < Iowa::Application; end
class MyComp < Iowa::DetachedComponent
	def awake
		self.class.template = "This is a test.  The time now is: @the_time."
	end

	def the_time
		Time.now.asctime
	end
end

class TC_SimpleDetached < Test::Unit::TestCase
	# init instance vars

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:simple_detached,"Simple Detached Component")
		assert_nothing_raised("setup failed") do
			ARGV.push(nil)
			@context = Iowa::Context.new
		end
	end

	def test_simple_detached
		assert_nothing_raised("Failure while testing simple detached component.") do
			component = MyComp.new('mycomp',[],[],nil)
			response = component.handleResponse(@context,true)
			puts response.inspect
			assert(response.body =~ /^This is a test.  The time now is: /,"The response from the detached component was not what was expected.")
		end
	end

end


