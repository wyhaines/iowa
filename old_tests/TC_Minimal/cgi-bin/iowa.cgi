#!/usr/bin/env ruby
$:.unshift(File.join('..','..','..'))
require 'iowa/Client.rb'

begin
iowa_socket = '127.0.0.1:47991'
client = Iowa::Client.new(iowa_socket)
client.handle_request
rescue Exception => e
	File.open('/tmp/ci.out','a+') {|fh| fh.puts e,e.backtrace.inspect}
end
