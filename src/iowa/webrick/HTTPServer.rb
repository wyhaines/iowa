require 'iowa'
require 'webrick'
require 'iowa/webrick/WEBrickServlet'

module Iowa
	class HTTPServer < WEBrick::HTTPServer
	
		def initialize(options)
			@mapfile = options.has_key?(:MapFile) ? options[:MapFile] : nil
			@mapfile_mtime = 0
			@mappings = {}
			Iowa.app.initialLoad
			@iowa_servlet = Iowa::WEBrickServlet
			super
		end

		def service(req,res)
			if req.unparsed_uri == "*"
				if req.request_method == "OPTIONS"
					do_OPTIONS(req, res)
					raise ::HTTPStatus::OK
				end
				raise ::HTTPStatus::NotFound, "`#{req.unparsed_uri}' not found."
			end

			servlet = options = script_name = path_info = nil
			if Iowa.app.class.Dispatcher.handleRequest?(req.path)
				servlet = @iowa_servlet
				script_name = 'Iowa'
				path_info = req.path
			else
				servlet, options, script_name, path_info = search_servlet(req.path)
			end
			raise ::HTTPStatus::NotFound, "`#{req.path}' not found." unless servlet
			req.script_name = script_name
			req.path_info = path_info
			si = servlet.get_instance(self, *options)
			@logger.debug(format("%s is invoked.", si.class.name))
			si.service(req, res)
		end

	end
end
