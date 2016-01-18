#!/usr/bin/env ruby
$:.unshift(File.join('..','..','..','src'))
require 'iowa/Client.rb'

iowa_socket = '127.0.0.1:47991'
client = Iowa::Client.new(iowa_socket)
client.handle_request
