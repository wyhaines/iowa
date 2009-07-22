require 'iowa'
require 'webrick'

# This is a _basic_ level of support.  I'm sure that I need to add things to
# deal with multipart/form-data forms for file uploads, and for providing some
# of the other information that is encapsulated in an Iowa::Request.

class Iowa::Request
	alias old_init initialize
	def initialize
		@headers_in = Iowa::R::Table.new
		@headers_out = Iowa::R::Table.new
		@params = {}
	end
end

class Iowa::WEBrickServlet < WEBrick::HTTPServlet::AbstractServlet

	#####
	#// This is the only magic.  It takes the place of the
	#// Iowa::handleConnection() method that is used when running in a
	#// non-webrick mode.
	#####
	def do_GET request, response
		Iowa::handleConnection(request,response)
	end
	alias do_POST do_GET
end
