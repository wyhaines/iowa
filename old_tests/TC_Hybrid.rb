require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'rbconfig'
require 'net/http'

if IWATestSupport.run_modes.include?(:hybrid)
	class TC_Hybrid < Test::Unit::TestCase

		@@testdir = IWATestSupport.test_dir(__FILE__)
		def setup
			Dir.chdir(@@testdir)
			IWATestSupport.announce(:hybridmode,"Hybrid Run Mode")
	
			ruby = File.join(::Config::CONFIG['bindir'],::Config::CONFIG['ruby_install_name'])
			ruby << ::Config::CONFIG['EXEEXT']
	
			assert_nothing_raised("setup failed") do
				@iowa_pid = IWATestSupport::create_process(:dir => 'TC_Hybrid/iowa',
					:cmd => ["#{ruby} -I../../../src app.rb -r hybrid"])
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

		def test_hybrid
			r = nil
			assert_nothing_raised("Error trying to send request to iowa app.") do
				response = get_url('127.0.0.1','47990','/')
				r = response.body
			end

			r =~ /<a href="([^"]+)">dynamic link/
			dlink = $1
			assert_match(/<a href="[^"]+">dynamic link/,r,"Failed to find expected dynamic link url.")
				
			dresponse = get_url('127.0.0.1','47990',dlink).body
			assert_match(/The time is now: /,dresponse,"Failed to get expected dynamic link result.")

			r =~ /<a href="([^"]+)">static link/
			slink = $1
			assert_match(/<a href="[^"]+">static link/,r,"Failed to find expected static link url.")

			sresponse = get_url('127.0.0.1','47990',slink).body
			assert_match(/This is a static thing./,sresponse,"Failed to get the expected static link result.")
		end

	end
end
