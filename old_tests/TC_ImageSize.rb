require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/ImageSize'

class TC_ImageSize < Test::Unit::TestCase

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:imagesize,"Iowa::ImageSize")
	end

	def testGIF
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.gif'))
		assert(img.type == 'GIF', "GIF type test failed; returned #{img.type}.")
		assert(img.width == 70, "GIF width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "GIF height test failed; returned #{img.height} instead of 34.")
	end

	def testPNG
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.png'))
		assert(img.type == 'PNG', "PNG type test failed; returned #{img.type}.")
		assert(img.width == 70, "PNG width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "PNG height test failed; returned #{img.height} instead of 34.")
	end

	def testJPEG
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.jpg'))
		assert(img.type == 'JPEG', "JPEG type test failed; returned #{img.type}.")
		assert(img.width == 70, "JPEG width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "JPEG height test failed; returned #{img.height} instead of 34.")
	end

	def testBMP
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.bmp'))
		assert(img.type == 'BMP', "BMP type test failed; returned #{img.type}.")
		assert(img.width == 70, "BMP width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "BMP height test failed; returned #{img.height} instead of 34.")
	end

	def testPPM
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.ppm'))
		assert(img.type == 'PPM', "PPM type test failed; returned #{img.type}.")
		assert(img.width == 70, "PPM width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "PPM height test failed; returned #{img.height} instead of 34.")
	end

	def testPGM
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.pgm'))
		assert(img.type == 'PPM', "PGM type test failed; returned #{img.type}.")
		assert(img.width == 70, "PGM width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "PGM height test failed; returned #{img.height} instead of 34.")
	end

	def testXBM
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.xbm'))
		assert(img.type == 'XBM', "XBM type test failed; returned #{img.type}.")
		assert(img.width == 70, "XBM width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "XBM height test failed; returned #{img.height} instead of 34.")
	end

	def testTIFF
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.tiff'))
		assert(img.type == 'TIFF', "TIFF type test failed; returned #{img.type}.")
		assert(img.width == 70, "TIFF width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "TIFF height test failed; returned #{img.height} instead of 34.")
	end

	def testPSD
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.psd'))
		assert(img.type == 'PSD', "PSD type test failed; returned #{img.type}.")
		assert(img.width == 70, "PSD width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "PSD height test failed; returned #{img.height} instead of 34.")
	end

	def testPCX
		img = Iowa::ImageSize.new(File.open('TC_ImageSize/img.pcx'))
		assert(img.type == 'PCX', "PCX type test failed; returned #{img.type}.")
		assert(img.width == 70, "PCX width test failed; returned #{img.width} instead of 70.")
		assert(img.height == 34, "PCX height test failed; returned #{img.height} instead of 34.")
	end

end
