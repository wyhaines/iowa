#!/usr/local/bin/ruby

require 'iowa'

class TCTestCGISession < Iowa::Session; end
class TCTestCGI < Iowa::Application; end

Iowa.run({:daemonize => false})
