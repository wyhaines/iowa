#require 'rubygems'
require 'test/unit'
require 'external/test_support'
require 'iowa/Association'

class TC_CSS < Test::Unit::TestCase
	def setup
		IWATestSupport.announce(:association,"Associations")
	end

	def test_association
		association = nil
		assert_nothing_raised { association = Iowa::Association.new('thing') }
		assert_equal('thing',association.association)
		assert(association.test(1),"test() should always return true for Iowa::Association.")
	end

	def test_literal_association
		association = nil
		assert_nothing_raised { association = Iowa::LiteralAssociation.new('foo') }
		assert_equal('foo',association.get)
		assert_nothing_raised { association.set(1,Proc.new { 7 }) }
		assert_equal(7,association.get)
	end

	def test_path_association
	end

end
