#!/usr/bin/env ruby

#FCGI_PURE_RUBY = true

require 'yaml'
require 'fcgi'
require 'iowa/Client'
require 'getoptlong'
require 'logger'

matchURI = Regexp.new('(/*(?:[^/]*/*)*?)(\w+\-\w+\-\w+\.\w+\.[\w\.]+)*(-\d+)?$')
matchLoc = Regexp.new('^(..)(..)(..)(..)(....)')

def read_configuration(file)
	File.open(file) {|cf| YAML::load(cf)}
end

def parse_configuration
	@config = read_configuration(@config_file)
	@socket_list = []
	@config.each do |k,v|
		next unless v
		@socket_list.push("#{k}:#{v}")
	end
	@config_length = @config.length
end

def open_logfile(lf)
	Logger.new(lf,'daily')
end

# Command line switches:
#  -f FILENAME
#    Specifies a configuration file.
#  -v Print the version and exit.
#  -l The process should log to this file.

options = GetoptLong.new(
	['--file', '-f', GetoptLong::REQUIRED_ARGUMENT],
	['--version', '-v', GetoptLong::NO_ARGUMENT],
	['--logfile','-l', GetoptLong::REQUIRED_ARGUMENT])

@logfile = nil
@config = {}
options.each do |opt, arg|
	case opt
	when '--file'
		# Configuration file format:
		#  IP/port: [true|false]
		#  num: /path/to/socket
		@config_file = arg
		parse_configuration
	when '--version'
		puts "v0.1 IOWA FCGI Muxxer; 02 March 2005"
		exit
	when '--logfile'
		@logfile = open_logfile(arg)
	end
end
	
FCGI.each do |request|
	env = request.env
	m = matchURI.match(env['REQUEST_URI'])
	ip = nil
	if m && m[2].to_s != ''
		l = matchLoc.match(m[2])
		if l
			ip = "#{l[0].hex}.#{l[1].hex}.#{l[2].hex}.#{l[3].hex}"
			port = l[4].hex
		end
	end
	
	if ip == '0.0.0.0' && @config.has_key?(port)
		# unix socket
		iowa_socket = @config[port]
	elsif ip && @config.has_key?("#{ip}/#{port}")
		# tcp socket
		iowa_socket = "#{ip}:#{port}"
	else
		# pick a random socket.
		id,sock = @socket_list[rand(@config_length)].split(/:/,2)
		if m = /\//.match(id)
			iowa_socket = id.sub(/\//,':')
		else
			iowa_socket = sock
		end
	end
	
	if @logfile
		@logfile.info("Dispatching request to #{iowa_socket}")
	end

	begin
		client = Iowa::Client.new(iowa_socket)
		client.handle_request({:request => request, :ios => request.out})
		request.finish
	rescue Exception => e
		@logfile.error("Error: #{e} -- #{e.backtrace.inspect}")
		request.finish
	end
end
