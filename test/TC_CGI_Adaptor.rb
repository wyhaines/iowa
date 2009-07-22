require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'rbconfig'
require 'net/http'

class TC_CGI_Adaptor < Test::Unit::TestCase

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:cgiadaptor,"Simple CGI Based App")
		ruby = File.join(::Config::CONFIG['bindir'],::Config::CONFIG['ruby_install_name'])
		ruby << ::Config::CONFIG['EXEEXT']

		assert_nothing_raised("setup failed") do
			@iowa_pid = IWATestSupport::create_process(:dir => 'TC_CGI_Adaptor/iowa',
				:cmd => [ruby,'-I../../../src','app.rb'])
			sleep 1
			@wb_pid = IWATestSupport::create_process(:dir => 'TC_CGI_Adaptor',
				:cmd => [ruby,'-I../../../src','webrick.rb'])
			sleep 1
		end
	end

	def teardown
		Process.kill 'SIGKILL',@iowa_pid
		Process.wait @iowa_pid
		Process.kill 'SIGKILL',@wb_pid
		Process.wait @wb_pid
		sleep 1
	end
	
	def get_url(hostname,port,url)
		Net::HTTP.start(hostname,port) {|http| http.get(url)}
	end

	def testBasicGet
		assert_nothing_raised("Error trying to send request to iowa app via CGI adaptor.") do
			response = get_url('127.0.0.1','47990','/cgi/iowa.cgi')
			assert(response.body =~ /The Time Is/,"The response returned from the iowa app is not what was expected.")
		end
	end

	def testFollowLink
		assert_nothing_raised("Error trying to send request to iowa app via CGI adaptor.") do
			response = get_url('127.0.0.1','47990','/cgi/iowa.cgi')
			response.body =~ /127.0.0.1:47990([^"]+)/m
			nextlink = $1
			response2 = get_url('127.0.0.1','47990',nextlink)
			assert(response2.body =~ /The count is 2/,"The response returned from the iowa app is not what was expected.\nResponse: #{response2.body}")
		end
	end

end
