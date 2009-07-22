require 'test/unit'
require 'external/test_support'
require 'iowa/AcceptLanguage'
require 'benchmark'

class TC_AcceptLanguage < Test::Unit::TestCase

	def setup_al(al)
		al['en-us'] = 'EN-US'
		al['en'] = 'EN'
		al['es'] = 'ES'
		al['es-es'] = 'ES-ES'
	end
	
	def setup
		IWATestSupport.announce(:acceptlanguage,"Accept Language Parser")
	end

	def test_a
		al = nil
		assert_nothing_raised("Error creating an AcceptLanguage object.") do
			al = Iowa::AcceptLanguage.new
		end
		assert_nothing_raised("Error assigning to an AcceptLanguage object.") do
			setup_al(al)
		end
		assert_equal(['en','en-us','es','es-es'],al.languages.sort,"The list of accepted languages does not match what was expected.")

		l = 'es-es,es;q=0.8,en-us;q=0.5,en;q=0.3'
		assert_equal('ES-ES',al.match(l))

		m = 'es-mx,es;q=0.8,en-us;q=0.5,en;q=0.3'
		assert_equal('ES',al.match(m))

		n = 'en-us,es;q=0.1'
		assert_equal('EN-US',al.match(n))

		o = 'en-gb,en;q=0.3'
		assert_equal('EN',al.match(o))

		p = 'en-gb'
		assert_equal('EN',al.match(p))

		puts "\nBenchmarking AcceptLanguage..."
		Benchmark.benchmark do |bm|
			bm.report do
				20000.times do
					al.match(l)
					al.match(m)
					al.match(n)
					al.match(o)
					al.match(p)
				end
			end
		end
	end

end



