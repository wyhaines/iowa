#!ruby

basedir = File.dirname(__FILE__)
$:.push(basedir)

require 'external/package'
require 'rbconfig'
begin
	require 'rubygems'
rescue LoadError
end

Dir.chdir(basedir)
Package.setup("1.0") {
	name "IOWA"

	build_ext "http11"
	translate(:ext, 'ext/http11/' => 'iowa/')
	ext "ext/http11/http11.so"

	build_ext "Classifier"
	translate(:ext, 'ext/Classifier/' => 'iowa/')
	ext "ext/Classifier/classifier.so"
	
	translate(:lib, 'src/' => '')
	lib ["src/iowa.rb","src/iowa_webrick.rb","src/iowa_mongrel.rb","src/iowa_httpmachine.rb","src/iowa_hybrid.rb","src/iowa_hybrid_cluster.rb"]
	lib(*Dir["src/iowa/**/*.rb"])
	lib "src/mod_iowa.rb" => "apache/mod_iowa.rb"
	ri(*Dir["src/iowa/**/*.rb"])
	ri ["src/iowa.rb","src/iowa_webrick.rb","src/iowa_mongrel.rb","src/iowa_httpmachine.rb","src/iowa_hybrid.rb","src/iowa_hybrid_cluster.rb","src/mod_iowa.rb"]

	begin
		require 'tmail'
	rescue LoadError
		# No tmail; install ours.
		translate(:lib, 'external/tmail/' => '')
		lib(*Dir["external/tmail/**/*.rb"])
		lib 'external/tmail/tmail/parser.y'
		ri ["external/tmail/tmail.rb","external/tmail/tmail"]
	end

	begin
		require 'mime-types'
	rescue LoadError
		# No mime-types; install the bundled one.
		translate(:lib, 'external/mime-types/lib/' => '')
		lib(*Dir["external/mime-types/lib/**/*"])
		ri ["external/mime-types/lib"]
		translate(:doc, 'external/mime-types/doc/' => 'mime-types/')
		doc(*Dir["external/mime-types/doc/**/*"])
	end

	if /win/ == Config::CONFIG['host_os']
		begin
			require 'windows/process'
		rescue LoadError
			# No windows-pr package; install bundled one.
			translate(:lib, 'external/windows-pr/lib/' => '')
			lib(*Dir["external/windows-pr/lib/**/*"])
			ri ["external/windows-pr/lib"]
			translate(:doc, 'external/windows-pr/doc/' => 'windows-pr/')
			doc(*Dir["external/windows-pr/doc/**/*"])

			$:.push File.join(basedir,'external/windows-pr/lib')
			require 'windows/error'
			require 'windows/process'
			require 'windows/synchronize'
			require 'windows/handle'
			require 'windows/library'
			require 'windows/console'
			require 'windows/window'

		end
		begin
			require 'win32/process'
		rescue LoadError
			# Now win32-process package; install bundled one.
			translate(:lib, 'external/win32-process/lib/' => '')
			lib(*Dir["external/win32-process/lib/**/*"])
			ri ["external/win32-process/lib"]

			$:.push File.join(basedir,'external/win32-process/lib')
			require 'win32/process'
		end
	end

	# Wrong.  Fix this.
	bin "src/iowa_fcgi_handler.rb"

	unit_test "test/TC_CSS.rb"
	unit_test "test/TC_AcceptLanguage.rb"
	unit_test "test/TC_AppConfig.rb"
	unit_test "test/TC_Association.rb"
	unit_test "test/TC_BiLevelCache.rb"
	unit_test "test/TC_CGI_Adaptor.rb"
	unit_test "test/TC_Classifier.rb"
	unit_test "test/TC_ClassLimitedCache.rb"
	unit_test "test/TC_DiskCache.rb"
	unit_test "test/TC_ImageSize.rb"
	unit_test "test/TC_ISAAC.rb"
	unit_test "test/TC_KeyValueCoding.rb"
	unit_test "test/TC_Lockfile.rb"
	unit_test "test/TC_LRUCache.rb"
	unit_test "test/TC_NoSubclass.rb"
	unit_test "test/TC_Pool.rb"
#	unit_test "test/TC_SimpleDetached.rb"
	unit_test "test/TC_StandardDispatcher.rb"
	unit_test "test/TC_StandardDispatcherWithClassifier.rb"
	unit_test "test/TC_String.rb"
	unit_test "test/TC_Tag.rb"
	unit_test "test/TC_ResourceURL.rb"
	unit_test "test/TC_Mongrel.rb"
	unit_test "test/TC_Hybrid.rb"
	unit_test "test/TC_Webrick.rb"
	true
}
