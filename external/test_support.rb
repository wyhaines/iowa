# A support module for the test suite.  This provides a win32 aware
# mechanism for doing fork/exec operations.  It requires win32/process
# to be installed, however.
#
module IWATestSupport
	@run_modes = []

	def self.create_process(args)
		@fork_ok = true unless @fork_ok == false
		pid = nil
		begin
			raise NotImplementedError unless @fork_ok
			unless pid = fork
				Dir.chdir args[:dir]
				exec(*args[:cmd])
			end
		rescue NotImplementedError
			@fork_ok = false
			begin
				require 'rubygems'
			rescue Exception
			end

			begin
				require 'win32/process'
			rescue LoadError
				raise "Please install win32-process to run all tests on a Win32 platform.  'gem install win32-process' or http://rubyforge.org/projects/win32utils"
			end
			cwd = Dir.pwd
			Dir.chdir args[:dir]
			pid = Process.create(:app_name => args[:cmd].join(' '))
			Dir.chdir cwd
		end
		pid
	end

	def self.test_dir(dir)
		File.dirname(File.expand_path(dir))
	end

	def self.cd_to_test_dir(dir)
		Dir.chdir(File.dirname(File.expand_path(dir)))
	end

	def self.set_src_dir
		$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'../src'))
	end

	@announcements = {}
	def self.announce(section,msg)
		unless @announcements.has_key?(section)
			puts "\n\n"
			puts msg,"#{'=' * msg.length}\n\n"
			@announcements[section] = true
		end
	end

	def self.run_modes
		if @run_modes.empty?
			@run_modes << :webrick

			# Test for Mongrel
			has_mongrel = true
			begin
				require 'mongrel'
			rescue
				has_mongrel = false
			end
			@run_modes << :mongrel if has_mongrel

			# Test for EventMachine
			has_em = true
			begin
				require 'eventmachine'
			rescue
				has_em = false
			end
			if has_em
				@run_modes << :hybrid
				@run_modes << :httpmachine
			end
		end
		@run_modes
	end

	def self.fastest_runmode
		[:hybrid,:mongrel].select {|mode| run_modes.include? mode}.first
	end

	def self.safest_runmode
		:webrick
	end

end

