require 'rbconfig'
require 'webrick'

class HTTPServer < WEBrick::HTTPServer
	
		def service(req,res)
			if req.unparsed_uri == "*"
				if req.request_method == "OPTIONS"
					do_OPTIONS(req, res)
					raise ::HTTPStatus::OK
				end
				raise ::HTTPStatus::NotFound, "`#{req.unparsed_uri}' not found."
			end

			servlet = options = script_name = path_info = nil
			servlet, options, script_name, path_info = search_servlet(req.path)
		
			raise ::HTTPStatus::NotFound, "`#{req.path}' not found." unless servlet
			req.script_name = script_name
			req.path_info = path_info
			si = servlet.get_instance(self, *options)
			@logger.debug(format("%s is invoked.", si.class.name))
			si.service(req, res)
		end

end

ruby = File.join(::Config::CONFIG['bindir'],::Config::CONFIG['ruby_install_name'])
ruby << ::Config::CONFIG['EXEEXT']

server = HTTPServer.new(
	:Port => 47990,
	:DocumentRoot => 'doc',
	:CGIInterpreter => ruby)

file_handler_options = {:HandlerTable => Hash.new(WEBrick::HTTPServlet::CGIHandler)}
server.mount('/cgi', WEBrick::HTTPServlet::FileHandler, File.join(Dir.getwd,'cgi'), file_handler_options)
server.start
