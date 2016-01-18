require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/classifier'
require 'benchmark'

class TC_Classifier < Test::Unit::TestCase
	@@testdir = IWATestSupport.test_dir(__FILE__)

	A = 'A'
	B = 'B'
	C = 'C'
	D = 'D'
	
	def setup
		IWATestSupport.announce(:classifier,"Iowa::Dispatchers::Classifier")
		assert_nothing_raised("setup failed") do
			@classifier = Iowa::Classifier.new
			@classifier['/'] = D
			@classifier['/index.htm'] = A
			@classifier['/images'] = B
			@classifier['/images/specific_image.'] = A
			@classifier['/images/specific_image.png'] = C
			@classifier['/funds'] = C
			@classifier['/funds/'] = D
			@classifier['/funds/index.html'] = C
			@classifier['/funds/abcdef/index.html'] = A
			@classifier['/funds/abcdef/data.html'] = B
			@plain_hash = {}
			@plain_hash['/'] = D
			@plain_hash['/index.htm'] = A
			@plain_hash['/images'] = B
			@plain_hash['/images/specific_image.'] = A
			@plain_hash['/images/specific_image.png'] = C
			@plain_hash['/funds'] = C
			@plain_hash['/funds/'] = D
			@plain_hash['/funds/index.html'] = C
			@plain_hash['/funds/abcdef/index.html'] = A
			@plain_hash['/funds/abcdef/data.html'] = B
		end
	end

	def test_classifier
		assert_equal('A',@classifier['/index.htm'],"Match(/index.htm) failed")
		assert_equal('A',@classifier['/index.html'],"Match(/index.html) failed")
		assert_equal('C',@classifier['/images/specific_image.png'],"Match(/images/specific_image.png) failed")
		assert_equal('A',@classifier['/images/specific_image.gif'],"Match(/images/specific_image.gif) failed")
		assert_equal('B',@classifier['/images/other_image.jpg'],"Match(/images/other_image.jpg) failed")
		assert_equal('B',@classifier['/images'],"Match(/images) failed")
		assert_equal('A',@classifier['/funds/abcdef/index.html'],"Match(/funds/abcdef/index.html) failed")
		assert_equal('B',@classifier['/funds/abcdef/data.html?abc=123'],"Match(/funds/abcdef/data.html?abc=123) failed")
		assert_equal('C',@classifier['/funds/index.html'],"Match(/funds/index.html) failed")
		assert_equal('D',@classifier['/funds/portfolio2.html'],"Match(/funds/portfolio2.html) failed")
		assert_equal('D',@classifier['/funds/portfolio.html'],"Match(/funds/portfolio.html) failed")
		assert_equal('C',@classifier['/funds.html'],"Match(/funds.html) failed")
		assert_equal('D',@classifier['/misc.html'],"Match(/misc.html) failed")
		$stderr.puts "\nHammering classifier lookups (1.3 million)..."
		Benchmark.bm do |bm|
			bm.report do
				100000.times do
					@classifier['/index.htm']
					@classifier['/index.html']
					@classifier['/images/specific_image.png']
					@classifier['/images/specific_image.gif']
					@classifier['/images/other_image.jpg']
					@classifier['/images']
					@classifier['/funds/abcdef/index.html']
					@classifier['/funds/abcdef/data.html?abc=123']
					@classifier['/funds/index.html']
					@classifier['/funds/portfolio2.html']
					@classifier['/funds/portfolio.html']
					@classifier['/funds.html']
					@classifier['/misc.html']
				end
			end
		end

	end

end
