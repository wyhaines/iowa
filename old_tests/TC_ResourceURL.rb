require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'rbconfig'
require 'net/http'

class TC_ResourceURL < Test::Unit::TestCase

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:resourceurls,"Iowa Resource URLs")
		@runmode = IWATestSupport.fastest_runmode

		ruby = File.join(::Config::CONFIG['bindir'],::Config::CONFIG['ruby_install_name'])
		ruby << ::Config::CONFIG['EXEEXT']

		assert_nothing_raised("setup failed") do
			@iowa_pid = IWATestSupport::create_process(:dir => 'TC_ResourceURL/iowa',
				:cmd => ["#{ruby} -I../../../src app.rb -r #{@runmode}"])
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

	def test_res1
		assert_nothing_raised("Error trying to send request to iowa app.") do
			response = get_url('127.0.0.1','47990','/')
			r = response.body
			r =~ /^Resource1: (.*)/
			response = get_url('127.0.0.1','47990',$1)
			assert_equal('abc123',response.body,"Static resources seem to be failing.")
			require 'benchmark'
			puts "\nStatic resources under #{@runmode} runmode; 2000 requests"
			Benchmark.bm do |bm|
				bm.report('static') do
					2000.times do
						response = get_url('127.0.0.1','47990',$1)
					end
				end
			end
		end
		puts "\n"

		assert_nothing_raised("Error trying to send request to iowa app.") do
			response = get_url('127.0.0.1','47990','/')
			r = response.body
			r =~ /^Resource2: (.*)/
			response = get_url('127.0.0.1','47990',$1)
			assert_equal('def456',response.body,"Dynamic resources seem to be failing.")
			require 'benchmark'
			puts "\nDynamic resources under #{@runmode}; 2000 requests"
			Benchmark.bm do |bm|
				bm.report('dynamic') do
					2000.times do
						response = get_url('127.0.0.1','47990',$1)
					end
				end
			end
		end
		puts "\n"
	end

end
