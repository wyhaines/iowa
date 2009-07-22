require 'test/unit'
require 'external/test_support'
IWATestSupport.set_src_dir
require 'iowa/dispatchers/StandardDispatcher'
require 'benchmark'

class ExternalRoutines
	def self.downcase(r)
		r.uri.downcase!
	end
end

class FauxPolicy
	def self.getIDs(_)
		[nil,nil]
	end
end

module Iowa
	def self.app
		Struct.new(:policy).new(FauxPolicy)
	end
end
		
class TC_StandardDispatcher < Test::Unit::TestCase

	@@testdir = IWATestSupport.test_dir(__FILE__)
	class Request
		attr_accessor :uri, :hostname, :params, :request_method
		def initialize(uri = nil, hostname = nil, params = nil, request_method = 'GET')
			@uri = uri
			@hostname = hostname
			@params = params
			@request_method = request_method
		end
	end

	def transforming(uri)
		print "\nTransforming #{uri} -> "
	end

	def processing(req)
		puts "\nProcessing request #{req.inspect} -> "
	end

	def setup
		Dir.chdir(@@testdir)
		IWATestSupport.announce(:standard_dispatcher,"Iowa::Dispatchers::StandardDisparcher")
	end

	def test_a_empty_struct
		rule_struct = []
		assert_nothing_raised("Failure parsing an empty ruleset") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
		end
	end

	def test_b_hash_struct1
		rule_struct = {:match => /view/, :sub => 'show'}
		rq = Request.new('/view/3')
		assert_nothing_raised("Failure while parsing ruleset.") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
			transforming rq.uri
			rs.process(rq)
			puts rq.uri
			assert_equal('/show/3',rq.uri,"The processed request did not return the expected result.")
		end
	end

	def test_c_hash_struct2
		rule_struct = {:match => 'view', :sub => 'show'}
		rq = Request.new('/view/3')
		assert_nothing_raised("Failure while parsing ruleset.") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
			transforming rq.uri
			rs.process(rq)
			puts rq.uri
			assert_equal('/show/3',rq.uri,"The processed request did not return the expected result.")
		end
	end

	def test_d_simple_struct
		rule_struct = [
			{:match => '[A-Z]', :gsub => '{|r,c| c.downcase}'},
			{:match => '\.htm$', :sub => '.html'},
			{:match => '^.*\.php\d*', :sub => '/php_unsupported.html'},
		]
		rqs = [
			Request.new('/foo/bar.htm'),
			Request.new('/app.php'),
			Request.new('/foo/BAR.HTM')
		]
		rqso = rqs.dup

		assert_nothing_raised("Failure while parsing ruleset.") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
			transforming rqso[0].uri
			rs.process(rqs[0])
			puts rqs[0].uri
			assert_equal('/foo/bar.html',rqs[0].uri,"Transformation incorrect.")

			transforming rqso[1].uri
			rs.process(rqs[1])
			puts rqs[1].uri
			assert_equal('/php_unsupported.html',rqs[1].uri,"Transformation incorrect.")

			transforming rqso[2].uri
			rs.process(rqs[2])
			puts rqs[2].uri
			assert_equal('/foo/bar.html',rqs[2].uri,"Transformation incorrect.")
		end
	end

	def test_e_simple_struct_call_external1
		rule_struct = [
			{:match => '[A-Z]', :call => '::ExternalRoutines.downcase'},
			{:match => '\.htm$', :sub => '.html'}
		]
		rqs = [
			Request.new('/foo2/bar.htm'),
			Request.new('/foo2/BAR.HTM')
		]
		rqso = rqs.dup

		assert_nothing_raised("Failure while parsing ruleset.") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
			transforming rqso[0].uri
			rs.process(rqs[0])
			puts rqs[0].uri
			assert_equal('/foo2/bar.html',rqs[0].uri,"Transformation incorrect.")

			transforming rqso[1].uri
			rs.process(rqs[1])
			puts rqs[1].uri
			assert_equal('/foo2/bar.html',rqs[1].uri,"Transformation incorrect.")
		end
	end

	def test_f_simple_struct_call_external2
		rule_struct = [
			{:match => '[A-Z]', :call => 'external_downcase'},
			{:match => '\.htm$', :sub => '.html'}
		]
		rqs = [
			Request.new('/foo3/bar.htm'),
			Request.new('/foo3/BAR.HTM')
		]
		rqso = rqs.dup

		assert_nothing_raised("Failure while parsing ruleset.") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
			transforming rqso[0].uri
			rs.process(rqs[0])
			puts rqs[0].uri
			assert_equal('/foo3/bar.html',rqs[0].uri,"Transformation incorrect.")

			transforming rqso[1].uri
			rs.process(rqs[1])
			puts rqs[1].uri
			assert_equal('/foo3/bar.html',rqs[1].uri,"Transformation incorrect.")
		end
	end

	def test_g_simple_struct_call_external3
		rule_struct = [
			{:match => '[A-Z]', :eval => 'request.uri.downcase!'},
			{:match => '\.htm$', :sub => '.html'}
		]
		rqs = [
			Request.new('/foo4/bar.htm'),
			Request.new('/foo4/BAR.HTM')
		]
		rqso = rqs.dup

		assert_nothing_raised("Failure while parsing ruleset.") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
			transforming rqso[0].uri
			rs.process(rqs[0])
			puts rqs[0].uri
			assert_equal('/foo4/bar.html',rqs[0].uri,"Transformation incorrect.")

			transforming rqso[1].uri
			rs.process(rqs[1])
			puts rqs[1].uri
			assert_equal('/foo4/bar.html',rqs[1].uri,"Transformation incorrect.")
		end
	end

	def test_h_branching
		rule_struct = [
			{:match => '{|request| request.hostname =~ /\.?foo\.com/}',
				:branch => [{:match => '(?i-mx:\.htm)$', :sub => '.html'}]},
			{:match => '{|request| request.hostname =~ /\.?bar\.com/}',
				:branch => [{:match => '[A-Z]', :eval => 'request.uri.downcase!'}]}
		]
		rqs = [
			Request.new('/INDEX.HTM','foo.com'),
			Request.new('/INDEX.HTM','www.foo.com'),
			Request.new('/INDEX.HTM','www.bar.com'),
			Request.new('/INDEX.HTM','fluffy.poodlelovers.com')
		]
		rqso = rqs.dup

		assert_nothing_raised("Failure while parsing ruleset.") do
			rs = Iowa::Dispatchers::StandardDispatcher::RuleSet.new(rule_struct)
			transforming "#{rqso[0].uri} @ #{rqso[0].hostname}"
			rs.process(rqs[0])
			puts rqs[0].uri
			assert_equal('/INDEX.html',rqs[0].uri,"Transformation incorrect.")

			transforming "#{rqso[1].uri} @ #{rqso[1].hostname}"
			rs.process(rqs[1])
			puts rqs[1].uri
			assert_equal('/INDEX.html',rqs[1].uri,"Transformation incorrect.")

			transforming "#{rqso[2].uri} @ #{rqso[2].hostname}"
			rs.process(rqs[2])
			puts rqs[2].uri
			assert_equal('/index.htm',rqs[2].uri,"Transformation incorrect.")

			transforming "#{rqso[3].uri} @ #{rqso[3].hostname}"
			rs.process(rqs[3])
			puts rqs[3].uri
			assert_equal('/INDEX.HTM',rqs[3].uri,"Transformation incorrect.")
		end
	end

	def test_i_processing
		mapfile = <<EMAPFILE
:rewrites:
- :match: "{|request| request.hostname =~ /\.?foo\.com/}"
  :branch: 
  - :match: "(?i-mx:\.htm)$"
    :sub: ".html"
- :match: "{|request| request.hostname =~ /\.?bar\.com/}"
  :branch:
  - :match: "[A-Z]"
    :eval: "request.uri.downcase!"
:map:
  /INDEX.html: CapIndex
  /index.htm: Index
  /INDEX.HTM: IndexHTM
  /randompix.png: RandomPix
EMAPFILE
		rqs = [
			Request.new('/INDEX.HTM','foo.com',{}),
			Request.new('/INDEX.HTM','www.foo.com',{}),
			Request.new('/INDEX.HTM','www.bar.com',{}),
			Request.new('/INDEX.HTM','fluffy.poodlelovers.com',{}),
			Request.new('/randompix.png','',{}),
			Request.new('/books',nil,{}),
			Request.new('/books/1',nil,{}),
			Request.new('/books/1',nil,{},'DELETE'),
			Request.new('/books/1',nil,{},'PUT'),
			Request.new('/books/new',nil,{}),
			Request.new('/books',nil,{},'POST'),
			Request.new('/books/1',nil,{'_method' => 'DELETE'},'POST'),
			Request.new('/books/1',nil,{'_method' => 'PUT'},'POST'),
			Request.new('/books/1;complete',nil,{},'POST'),
			Request.new('/books/show/ab4814f904/5/new',nil,{}),
			Request.new('/books/ab4814f904/5/new;show',nil,{})
		]
		rqso = rqs.dup

		require 'stringio'
		require 'yaml'
		mf = YAML.load(StringIO.new(mapfile))
		puts mf.inspect
		#assert_nothing_raised("Failure while parsing ruleset.") do
			disp = Iowa::Dispatchers::StandardDispatcher.new(mf)
			dd = disp.process(rqs[0])
			processing rqso[0]
			puts "**  #{dd.inspect}"
			assert(dd.component == 'CapIndex',"CapIndex1: Processing with result from map failed.")

			dd = disp.process(rqs[1])
			processing rqso[1]
			puts "  #{dd.inspect}"
			assert(dd.component == 'CapIndex',"CapIndex2: Processing with result from map failed.")

			dd = disp.process(rqs[2])
			processing rqso[2]
			puts "  #{dd.inspect}"
			assert(dd.component == 'Index',"Index: Processing with result from map failed.")

			dd = disp.process(rqs[3])
			processing rqso[3]
			puts "  #{dd.inspect}"
			assert(dd.component == 'IndexHTM',"IndexHTM: Processing with result from map failed.")

			dd = disp.process(rqs[4])
			processing rqso[4]
			puts "  #{dd.inspect}"
			assert(dd.component == 'RandomPix',"RandomPix: Processing with result from map failed.")

			dd = disp.process(rqs[5])
			processing rqso[5]
			puts "  #{dd.inspect}"
			assert(dd.component == 'books',"Processing RESTful request failed.")

			dd = disp.process(rqs[6])
			processing rqso[6]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'show') and (dd.args == ["1"])),"Processing RESTful request failed.")

			dd = disp.process(rqs[7])
			processing rqso[7]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'destroy') and (dd.args == ["1"])),"Processing RESTful DELETE request failed.")

			dd = disp.process(rqs[8])
			processing rqso[8]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'update') and (dd.args == ["1"])),"Processing RESTful PUT request failed.")

			dd = disp.process(rqs[9])
			processing rqso[9]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'new')),"Processing RESTful GET to invoke 'new' request failed.")

			dd = disp.process(rqs[10])
			processing rqso[10]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'create')),"Processing RESTful POST to invoke 'create' request failed.")

			dd = disp.process(rqs[11])
			processing rqso[11]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'destroy') and (dd.args == ["1"])),"Processing RESTful POST to invoke DELETE request failed.")

			dd = disp.process(rqs[12])
			processing rqso[12]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'update') and (dd.args == ["1"])),"Processing RESTful POST to invoke PUT request failed.")

			dd = disp.process(rqs[13])
			processing rqso[13]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'complete') and (dd.args == ["1"])),"Processing RESTful POST to invoke 'complete' request failed.")

			dd = disp.process(rqs[14])
			processing rqso[14]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'show') and (dd.args == ["ab4814f904","5","new"])),"Processing RESTful POST to invoke 'complete' request failed.")

			dd = disp.process(rqs[15])
			processing rqso[15]
			puts "  #{dd.inspect}"
			assert(((dd.component == 'books') and (dd.method == 'show') and (dd.args == ["ab4814f904","5","new"])),"Processing RESTful POST to invoke 'complete' request failed.")

			rqs = rqso.dup
			rqs.each {|rq| assert(disp.handleRequest?(rq),"handleRequest? says it won't handle #{rq.inspect}")}

			puts "\nDoing a quick benchmark of request processing using all of the test cases; 20000 * #{rqs.length} == #{20000 * rqs.length} requests."
			Benchmark.benchmark {|bm| bm.report {20000.times {rqs.each {|rq| dd = disp.process(rq)}}}}
		#end
	end
end

def external_downcase(r)
	r.uri.downcase!
end
