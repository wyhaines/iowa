#!/usr/local/bin/ruby
require 'iowa'
require 'iowa_mongrel' unless Iowa.runmode != :standalone

Iowa.run
