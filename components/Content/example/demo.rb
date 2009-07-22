require 'rbconfig'

def setup
	ruby = File.join(::Config::CONFIG['bindir'],::Config::CONFIG['ruby_install_name'])
	ruby << ::Config::CONFIG['EXEEXT']

	unless @iowa_pid = fork
		Dir.chdir('iowa')
		exec(ruby,'app.rb')
	end
	sleep(1)

	unless @wb_pid = fork
		exec(ruby,'webrick.rb')
	end

	Signal.trap("SIGINT") {teardown}
	Signal.trap("SIGTERM") {teardown}
	sleep(1)
end

def teardown
	puts "Shutting down."
	Process.kill 15,@iowa_pid
	Process.kill 15,@wb_pid
	exit
end

setup
sleep(99999) while true;
