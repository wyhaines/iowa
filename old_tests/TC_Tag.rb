require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/Constants'
require 'iowa/Context'
require 'iowa/Element'
require 'iowa/Tag'

class TC_Tag < Test::Unit::TestCase
	@tag

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:tag,"Iowa::Tag")
		assert_nothing_raised("Failed while creating an Iowa::Tag object") do
			@tag = Iowa::Tag.new('test',[],{})
		end
	end

	def testTagName
		assert_nothing_raised("Failed while returning the tagName.") do
			tagname = @tag.tagName
			assert_equal('tag',tagname,"The expected tagName (tag) did not match the returned tagname (#{tagname}).")
		end
	end

	def testOpenTag
		assert_nothing_raised("Failed while returning the openTag.") do
			opentag = @tag.openTag('name','test')
			assert_equal('<tag name="test">',opentag,"The expected openTag (<tag name='test'>) did not match the returned openTag (#{opentag}).")
		end
	end

	def testCloseTag
		assert_nothing_raised("Failed while returning the closeTag.") do
			closetag = @tag.closeTag
			assert_equal("</tag>",closetag,"The expected closeTag (<tag name='test'>) did not match the returned closeTag (#{closetag}).")
		end
	end
end
