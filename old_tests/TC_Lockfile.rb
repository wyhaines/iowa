require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/Lockfile'
require 'tmpdir'
require 'fileutils'

class TC_Lockfile < Test::Unit::TestCase
	@@disclaimer = false
	def make_tmp_path; "#{Dir::tmpdir}/tc_diskcache.#{Time.now.to_i}#{rand}.lck"; end

	@@testdir = IWATestSupport.test_dir(__FILE__)
	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:lockfile,"Iowa::Lockfile")
    puts "Be advised that if you are on certain OSes, such\nas Windows XP, the lockfile tests using link() will fail.\nThis is expected." unless @@disclaimer
		@@disclaimer = true
		assert_nothing_raised("setup failed") do
			@count = 0
		end
	end

	def thread_a
		puts "\nEntering thread A."
		@lockfile.lock do
			puts "#{Time.now.asctime}: Thread A acquired lock."
			sleep 3
			puts "#{Time.now.asctime}: Thread A releasing lock."
		end
	end

	def thread_b
		puts "Entering thread B."
		@lockfile.lock do
			puts "#{Time.now.asctime}: Thread B acquiring lock."
			sleep 1
			puts "#{Time.now.asctime}: Thread B releasing lock."
		end
	end

	def thread_c
		puts "Entering thread C."
		@lockfile.lock do
			puts "#{Time.now.asctime}: Thread C acquiring lock."
			sleep 1
			puts "#{Time.now.asctime}: Thread C releasing lock."
		end
	end

	def do_test
		tl = []
		tl.push Thread.new {thread_a}
		sleep 1
		tl.push Thread.new {thread_b}
		tl.push Thread.new {thread_c}
		tl.each {|t| t.join}
		sleep 1
	end

	def hammer
		1.upto(3000) do |x|
			@lockfile.lock do
				@count += 1
				if x % 100 == 0
					print '.'
					$stdout.flush
				end
			end
		end
	end

	# Tests go here.
	
	def test_a_link_method
		assert_nothing_raised("Failed while testing link() method.  On certain OSes (WinXP), this is expected.") do
			@lockfile = Iowa::Lockfile.new(make_tmp_path,{:use_flock => false})
			do_test
		end
	end

	def test_a_flock_method
		assert_nothing_raised("Failed while testing flock method.") do
			@lockfile = Iowa::Lockfile.new(make_tmp_path,{:use_flock => true})
			do_test
		end
	end

	def test_a_autoselect_method
		assert_nothing_raised("Failed while testing method autodetect.") do
			@lockfile = Iowa::Lockfile.new(make_tmp_path)
			do_test
		end
	end

	def test_hammer_lockfile
		assert_nothing_raised("Failed on lock #{@count} while hammering lockfile.") do
			@lockfile = Iowa::Lockfile.new(make_tmp_path)
			tl = []
			tl.push Thread.new {hammer}
			tl.push Thread.new {hammer}
			tl.each {|t| t.join}
			sleep 1
			assert_equal(6000,@count,"The final count (#{@count}) was not what was expected (60000).  Locking error may be responsible.")
		end
	end
end
