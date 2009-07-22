#!/usr/bin/env ruby

=begin

This is a simple CGI adaptor that will allow one to use Iowa with any CGI
capable web server without requiring any special permissions with regard
to web server configuration.

To install the Iowa CGI adaptor:
	-	Copy this file into your cgi-bin directory.
	-	Set up a url that invokes this script. 
	   In Apache, this involves adding something like this to your httpd.conf file:

			Action iowaGuestbook /cgi-bin/iowa_guestbook_adaptor.cgi
			<Location /guestbook>
				SetHandler iowaGuestbook
			</Location> 

Configuration of the script is simple.  Simply replace the text below that
reads, "[REPLACE_WITH_SOCKET_DEF]" with a valid socket definition
that points to where your Iowa application is listening.
	
=end

require 'iowa/Client'

iowa_socket = '[REPLACE_WITH_SOCKET_DEF]'
client = Iowa::Client.new(iowa_socket)
client.handle_request