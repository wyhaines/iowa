Iowa.runmode = :webrick
require 'iowa/Client'
require 'iowa/request/WEBrick'
require 'webrick'

module Iowa
  module WEBrick
    class SwallowLogs
      def method_missing(*args)
      end
    end

    class IWAServlet < ::WEBrick::HTTPServlet::AbstractServlet
      def deliver_file(response, filename, suffix)
        d = File.read(filename)
        ct = MIME::Types.type_for("foo.#{suffix}").first
        response["Date"] = Time.now.httpdate
        response["Connection"] = "close"
        response["Content-type"] = ct ? ct.content_type : 'application/octet-stream'
        response["Content-Length"] = d.length
        response.body = d
        Logger[Ciowa_log].info "Delivered static file: #{filename}"
      end

      def handle_file(request,response)
        path_info = request.path
        qs = request.query_string
        if path_info == C_slash or path_info == C_empty
          path_info = C_slashindex_html
        elsif path_info =~ /^([^.]+)$/
          path_info = "#{$1}/index.html"
        end
  
        qsfilename = "#{Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}__#{qs}"
        filename = "#{Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]}#{path_info}"
        if (FileTest.exist?(filename) and  File.expand_path(filename).index(Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
          suffix = path_info.sub(/[_\s]*$/,C_empty)
          deliver_file(response, filename, File.extname(suffix)[1..-1])
          true
        elsif qs and (FileTest.exist?(qsfilename) and File.expand_path(qsfilename).index(Iowa.config[Iowa::Capplication][Iowa::Cdoc_root]) == 0)
          suffix = path_info.sub(/[_\s]*$/,C_empty)
          deliver_file(qsfilename, File.extname(suffix)[1..-1])
          true
        else
          false
        end
      end
      
      def do_GET request, response
        unless handle_file(request,response)
          rq = Iowa::Request::WEBrick.new(request)
          rs = Iowa::handleConnection(rq)
        
          response.status = rs.status
          response.reason_phrase = ::Iowa::Response::RESPONSE_CODES[rs.status]
          response["Date"] = Time.now.httpdate
          response["Connection"] = "close"
          response["Content-type"] = rs.content_type || "text/html"
          response["Content-Length"] = rs.body.length
          rs.headers.each {|k,v| response[k] = v}
          response.body = rs.body
        end
      end
      alias do_POST do_GET
    end
    
    
    class HTTPServer < ::WEBrick::HTTPServer
  
      def initialize(options)
        @mappings = {}
        @iowa_servlet = Iowa::WEBrick::IWAServlet
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

        servlet, options, script_name, path_info = search_servlet(req.path)
        unless servlet
          servlet = @iowa_servlet
          script_name = 'Iowa'
          path_info = req.path
        end
        req.script_name = script_name
        req.path_info = path_info
        si = servlet.get_instance(self, *options)
        si.service(req, res)
      end
    end
  end
end

module Iowa

  # Handle the communications coming in on the monitored socket,
  # create a context object from the data received, and then pass
  # the context information into the Application object for final
  # handling.
  
  def self.handleConnection(request)
    start_time = read_time = Time.now
    mylog = Logger[Ciowa_log]

    status = []
    response = handleRequest(request)
    begin
      response.status_line = request.status_line if request.status_line
      response.content_type = request.content_type if request.content_type
      status[0] = response.status_line
      if request.headers_out.respond_to?(:length) and request.headers_out.length > 0
        request.headers_out.each {|k,v| response.headers.set(k,v)}
      end
    rescue Exception => e
      mylog.info e.to_s, e.backtrace.inspect
    end

    end_time = Time.now
    logline = "#{start_time} (#{read_time - start_time}/#{end_time - start_time}) :: #{request.uri} \"#{status[0]}\" #{response.body.length}B"
    mylog.info logline
    response
  end

  # Outputs the location of the socket being monitored, then enters the
  # event loop to wait for and handle connections.

  def self.eventLoop(server)
    Logger[Ciowa_log].info 'Entering the WEBrick event loop...'
    server.start
  end

  def self.run(*args)
    run_check_started(*args)
    mylog = Logger[Ciowa_log]
    my_ip = @config[Csocket][Chostname]
    my_ip_hex = my_ip.split('.',4).collect {|x| to_hex(x)}.join

    ruby = File.join(::RbConfig::CONFIG['bindir'],
      ::RbConfig::CONFIG['ruby_install_name']) << ::RbConfig::CONFIG['EXEEXT']
    
    if @config[Csocket].has_key? Cport
      socket_host = @config[Csocket][Chostname]
      socket_port = @config[Csocket][Cport]
      my_port_hex = sprintf('%04s',socket_port.to_i.to_s(16)).gsub(' ','0')
      Iowa.app.location = "#{my_ip_hex}#{my_port_hex}"
    else
      if Iowa.app.serial_number.to_s != ''
        Iowa.app.location = "00000000#{sprintf('%04s',Iowa.app.serial_number.to_i.to_s(16)).gsub(' ','0')}"
      else
        Iowa.app.location = ''
      end
    end


    app.initialLoad()
    setup_signal_handlers

    swallow_logs = Iowa::WEBrick::SwallowLogs.new

    @server = Iowa::WEBrick::HTTPServer.new(
      :Port => @config[Csocket][Cport],
      :BindAddress => @config[Csocket][Chostname],
      :DocumentRoot => Iowa.app.class.docroot,
      :Logger => swallow_logs,
      :AccessLog => swallow_logs,
      :CGIInterpreter => ruby)
    
    if Iowa.app.class.cgiroot and FileTest.exist?(Iowa.app.class.cgiroot)
      file_handler_options = {:HandlerTable => Hash.new(::WEBrick::HTTPServlet::CGIHandler)}
      prefix = Iowa.app.class.cgiroot =~ /cgi-bin/ ? '/cgi-bin' : 'cgi'
      @server.mount(prefix, ::WEBrick::HTTPServlet::FileHandler, Iowa.app.class.cgiroot, file_handler_options)
    end
    @server.mount('/',Iowa::WEBrick::IWAServlet)
    
    setup_signal_handlers

    begin
      eventLoop(@server)
    rescue Exception => exception
      mylog.fatal "Catastrophic failure in main event loop: #{exception} :: " + exception.backtrace.join(".....").to_s
    ensure
      File.delete(@config[Csocket][Cpath]) if @config[Csocket].has_key? Cpath
      @server.shutdown
      exit
    end
  end
end

