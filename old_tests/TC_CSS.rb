#require 'rubygems'
require 'test/unit'
require 'external/test_support'
require 'iowa/CSS'

class TC_CSS < Test::Unit::TestCase
	def setup
		IWATestSupport.announce(:cssdsl,"Dynamic CSS Generation/DSL")
		assert_nothing_raised("setup failed") do
			@css = Iowa::CSS.new
			@@longchunk ||= ''
		end
	end

	def test_css1_a
		cdef = <<ECSS
		h1 { color 'blue' }
ECSS
		cmp = <<ECSS
h1 {
  color: blue;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end
		
	def test_css1_b
		cdef = <<ECSS
Media.screen {
  h1 {
    color 'blue'
  }
}
ECSS
		cmp = <<ECSS
@media screen {
  h1 {
    color: blue;
  }
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css1_c
		cdef = <<ECSS
head_2 = h2 {
  color 'green'
  font_weight 'italic'
}

Id.content {
  Class.foo {
    border 3.px
    color head_2.color
  }
  font_face 'verdana'
  table {
    width 100
    Class.special {
      background_color 'grey'
    }
  }
}
ECSS
		@@longchunk << cdef
		cmp = <<ECSS
#content {
  font-face: verdana;
}
#content.foo {
  border: 3.0px;
  color: green;
}
#content table {
  width: 100;
}
#content table.special {
  background-color: grey;
}
h2 {
  color: green;
  font-weight: italic;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css1_d
		cdef = <<ECSS
p {
  quote {
    font_style :italic
    color :green
  }
}

z = nil
p {
  universal {
    quote {
      z = font {
        style 'italic'
        weight 'bold'
      }
      color 'green'
    }
  }
}

universal {
  Class.smaller {
    font {
      size 85.pct
      style z.style
      weight z.weight
    }
  }
}
ECSS
		cmp = <<ECSS
p quote {
  font-style: italic;
  color: green;
}
p * quote {
  font-style: italic;
  font-weight: bold;
  color: green;
}
*.smaller {
  font-size: 85.0%;
  font-style: italic;
  font-weight: bold;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css1_e
		cdef = <<ECSS
p {
  p {
    font {
      size 10.pt + 2
    }
  }
}
ECSS
		cmp = <<ECSS
p p {
  font-size: 12.0pt;
}
ECSS
		@@longchunk << cdef
		@css.parse(cdef)
		assert_equal(cmp,@css.to_s)
	end

	def test_css1_f
		cdef = <<ECSS
p {
  font_size 12.px + 4.pt;
}
ECSS
    assert_raise(Iowa::CSS::ApplesAndOrangesException) {@css.parse cdef}
	end

	def test_css1_g
		cdef = <<ECSS
Literal("/* this is a comment */")
ECSS
		cmp = "/* this is a comment */"
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css1_h
		cdef = <<ECSS
bstyle = "1px solid black"
table {
	tr {
		Group(Tag.td,Tag.th,Class.cell) {
			border {
				left bstyle
				bottom bstyle
			}
		}
		td {
			Class.last { border_right bstyle }
		}
	}
}
ECSS
		cmp = <<ECSS
table tr td {
  border-left: 1px solid black;
  border-bottom: 1px solid black;
}
table tr th {
  border-left: 1px solid black;
  border-bottom: 1px solid black;
}
table tr.cell {
  border-left: 1px solid black;
  border-bottom: 1px solid black;
}
table tr td.last {
  border-right: 1px solid black;
}
ECSS
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css2_a
		cdef = <<ECSS
universal {
  Class.smaller {font_size '85%'}
}
ECSS
		cmp = <<ECSS
*.smaller {
  font-size: 85%;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css2_b
		cdef = <<ECSS
img('border') {margin '5px'}
img('src="logo.gif"') {border 0}
td("headers!=col1") {color '#f00'}
ECSS
		cmp = <<ECSS
img[border] {
  margin: 5px;
}
img[src="logo.gif"] {
  border: 0;
}
td[headers!=col1] {
  color: #f00;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css2_c
		cdef = <<ECSS
romeo(:before) {content 'Romeo:'}
div {
  Class.section(:first_child,:first_letter) {font_size '200%'}
}
ECSS
		cmp = <<ECSS
romeo:before {
  content: Romeo:;
}
div.section:first_child:first_letter {
  font-size: 200%;
}
ECSS
		@@longchunk << cdef
		@css.parse(cdef)
		assert_equal(cmp,@css.to_s)
	end

	def test_css2_d
		cdef = <<ECSS
div {
  Class.resources {
    Child.a {color 'white'}
  }
}
ECSS
		cmp = <<ECSS
div.resources > a {
  color: white;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css2_e
		cdef = <<ECSS
p {text_indent '0.5in'}
h2 {Adjacent.p {text_index 0}}
ECSS
		cmp = <<ECSS
p {
  text-indent: 0.5in;
}
h2 + p {
  text-index: 0;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css2_f
		cdef = <<ECSS
link('hreflang|=en') {color 'black'}
ECSS
		cmp = <<ECSS
link[hreflang|=en] {
  color: black;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css2_g
				# html:lang(en){color: black;}
				# html:lang(es){color: #200;}
		cdef = <<ECSS
html(:lang => 'en') {color 'black'}
html(:lang => 'es') {color '#200'}
ECSS
		cmp = <<ECSS
html:lang(en) {
  color: black;
}
html:lang(es) {
  color: #200;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css3_a
		cdef = <<ECSS
a("href^='http://sales.'") {color 'teal'}
a("href$='.jsp'") {color 'purple'}
img("src*='artwork'") {
  border_color '#C3B087 #FFF #FFF #C3B087'
}
ECSS
		cmp = <<ECSS
a[href^='http://sales.'] {
  color: teal;
}
a[href$='.jsp'] {
  color: purple;
}
img[src*='artwork'] {
  border-color: #C3B087 #FFF #FFF #C3B087;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css3_b
		cdef = <<ECSS
_(:root) {overflow 'auto'}
ECSS
		cmp = <<ECSS
:root {
  overflow: auto;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css3_c
		cdef = <<ECSS
div {
  Class.article {
    Child.p(:last_child) {font_style 'italic'}
  }
}
ECSS
		cmp = <<ECSS
div.article > p:last_child {
  font-style: italic;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css3_d
		cdef = <<ECSS
span {
  Class.notice(:target) {
    font_size '2em'
    font_style 'bold'
  }
}
ECSS
		cmp = <<ECSS
span.notice:target {
  font-size: 2em;
  font-style: bold;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css3_e
		cdef = <<ECSS
tt {font_weight 'bold'}
table {Indirect.tt {font_weight 'normal'}}
ECSS
		cmp = <<ECSS
tt {
  font-weight: bold;
}
table ~ tt {
  font-weight: normal;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css3_f
		cdef = <<ECSS
img(:not => "border") {border 1}
img([{:lang => 'en'},{:not => 'border'}]) {border '2px solid red'}
img(:not => {:lang => 'en'}) {border '1px dotted green'}
ECSS
		cmp = <<ECSS
img:not([border]) {
  border: 1;
}
img:lang(en):not([border]) {
  border: 2px solid red;
}
img:not(:lang(en)) {
  border: 1px dotted green;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_css3_g
		cdef = <<ECSS
radio {
  Class.creditcard_type(:disabled) {color 'gray'}
}
input(:checked) {
  background_color 'blue'
  color 'white'
}
input {
  Class.required(:indeterminant) {color 'red'}
}
ECSS
		cmp = <<ECSS
radio.creditcard_type:disabled {
  color: gray;
}
input:checked {
  background-color: blue;
  color: white;
}
input.required:indeterminant {
  color: red;
}
ECSS
		@@longchunk << cdef
		@css.parse cdef
		assert_equal(cmp,@css.to_s)
	end

	def test_cssxtra_a
		n = 1000
		puts "\n\nParsing #{@@longchunk.length} bytes #{n} times....\n"
		require 'benchmark'
		assert_nothing_raised do
			Benchmark.bm {|bm| bm.report {n.times {@css.parse @@longchunk;@css.clear_output}}}
			print "\n" 
		end
		@css.parse @@longchunk
		@@generated_css = @css.to_s
	end

	def test_cssxtra_b
		cdef = <<ECSS
on_condition {false}.then {
  body { font_size 14.px }
}.elsif {false}.then {
  body { font_size 18.px }
}.else {
  body { font_size 16.px }
}
ECSS
		@css.parse cdef
		assert_equal('0/0/1',@css.condition_fingerprint)
		assert_equal("body {\n  font-size: 16.0px;\n}\n",@css.to_s)
	end

	def test_cssxtra_c
		cdef = <<ECSS
on_condition {false}.then {
  body { font_size 14.px }
}.elsif {true}.then {
  body { font_size 18.px }
}.else {
  body { font_size 16.px }
}
ECSS
		@css.parse cdef
		assert_equal('0/1/1',@css.condition_fingerprint)
		assert_equal("body {\n  font-size: 18.0px;\n}\n",@css.to_s)
	end

	def test_cssxtra_d
		cdef = <<ECSS
on_condition {true}.then {
  body { font_size 14.px }
}.elsif {false}.then {
  body { font_size 18.px }
}.else {
  body { font_size 16.px }
}
ECSS
		@css.parse cdef
		assert_equal('1/0/1',@css.condition_fingerprint)
		assert_equal("body {\n  font-size: 14.0px;\n}\n",@css.to_s)
	end

	def test_cssxtra_e
		cdef = <<ECSS
on_condition {true}.then {
  body { font_size 14.px }
}.elsif {true}.then {
  body { font_size 18.px }
}.else {
  body { font_size 16.px }
}
ECSS
		@css.parse cdef
		assert_equal('1/1/1',@css.condition_fingerprint)
		assert_equal("body {\n  font-size: 14.0px;\n}\n",@css.to_s)

	end

	def test_cssxtra_f
		cdef = <<ECSS
on_condition {false}.then {
  body { font_size 14.px }
}.elsif {false}.then {
  body { font_size 18.px }
}.else {
  body { font_size 16.px }
}
ECSS
	end

	def test_cssxtra_g
		cdef = <<ECSS
on_condition {|c| c == 'small'}.then {
  body { font_size 12.px }
}.elsif {|c| c == 'large'}.then {
  body { font_size 18.px }
}.else {
  body { font_size 15.px }
}
ECSS
		@css = Iowa::CSS.new(cdef)
		context = ['small','medium','large']
		cmp = []
		cmp << <<ECSS
body {
  font-size: 18.0px;
}
ECSS
		cmp << <<ECSS
body {
  font-size: 15.0px;
}
ECSS
		cmp << <<ECSS
body {
  font-size: 12.0px;
}
ECSS
		context.each do |c|
			@css.render(c)
			assert_equal(cmp.pop,@css.to_s)
		end
	end

	def test_cssxtra_h
		@css_nocache = Iowa::CSS.new(@@longchunk)
		@css_cache = Iowa::CSS.new(@@longchunk,true)
		n = 100000
		puts "\n\nRendering #{n} times with caching (no conditions)....\n"
		assert_nothing_raised do
			Benchmark.bm do |bm|
				bm.report {n.times {@css_cache.render}}
			end
		end
		print "\n"
		assert_equal(@@generated_css,@css_cache.render)
	end

	def test_cssxtra_i
		cdef = <<ECSS
on_condition {|c| c == 'small'}.then {
  body { font_size 12.px }
}.elsif {|c| c == 'large'}.then {
  body { font_size 18.px }
}.else {
  body { font_size 15.px }
}
ECSS
		@css = Iowa::CSS.new(cdef,true)
		context = ['small','medium','large']
		n = 33333
		puts "\n\nRendering #{n * 3} times with caching and three conditional versions....\n"
		assert_nothing_raised do
			Benchmark.bm do |bm|
				bm.report do
					n.times do 
						context.each do |c|
							@css.render(c)
						end
					end
				end
			end
		end
		print "\n"
	end

end
