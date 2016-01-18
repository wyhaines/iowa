require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'rbconfig'
require 'net/http'

class TC_AppConfig < Test::Unit::TestCase

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:appconfig,"Iowa App Configuration")

		ruby = File.join(::Config::CONFIG['bindir'],::Config::CONFIG['ruby_install_name'])
		ruby << ::Config::CONFIG['EXEEXT']

		assert_nothing_raised("setup failed") do
			@iowa_pid = IWATestSupport::create_process(:dir => 'TC_AppConfig/iowa',
				:cmd => [ruby,'-I../../../src','app.rb'])
			sleep 1
		end
	end

	def teardown
		Process.kill "SIGKILL",@iowa_pid
		Process.wait @iowa_pid
		sleep 1
	end
	
	def get_url(hostname,port,url)
		Net::HTTP.start(hostname,port) {|http| http.get(url)}
	end

	def testGetConfig
		assert_nothing_raised("Error trying to send request to iowa app via CGI adaptor.") do
			response = get_url('127.0.0.1','47990','/cgi/iowa.cgi')
			puts response.body
			assert(response.body =~ /"maxsize"=>200/, "The response returned from the iowa app has a malformed sessioncache entry.")
			assert(response.body =~ /Policy: Iowa::Policy/, "The response returned indicates that the Policy setting was not handled correctly.")
		end
	end

end
