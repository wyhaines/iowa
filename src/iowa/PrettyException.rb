###################################################
# Original Author:: Dmitry V. Sabanin <sdmitry@lrn.ru>
# License:: LGPL
#
# Modified for IOWA by Kirk Haines
###################################################

require 'rdoc'
require 'rbconfig'

###################################################
# Web PrettyPrint for Exceptions
#
module Iowa

	class PrettyException
	
	  attr_writer :message
	  
	  ###################################################
	  def initialize(exception, tplpath = nil)
	    @tplpath = tplpath
	    @exception = exception
	    @message = nil
	  end
	  ###################################################
	  
	  ###################################################
	  def build_template
	    tmpl = 
	    if @tplpath and File.exists?(@tplpath)
	      File.read(@tplpath)
	    else
	      tplfile = File.readlines(__FILE__)
	      start = nil
	      tplfile.each_with_index do |line,idx|
	        if line =~ /^__END__\s*$/
	          start = idx + 1
	          break
	        end
	      end
	      tplfile[start..-1].join('')
	    end
	
	    return TemplatePage.new(tmpl)
	  end
	  ###################################################
	  
	  ###################################################
	  def gen_source(file, line, mark_line = true)
	    source = File.readlines(file)
	    source = hilite_source(source)
	    line = line.to_i
	    if mark_line
	      show = 3
	      begin_from = line - show
	      end_at = line + show 
	      begin_from = begin_from > 0 ? begin_from : 0
	      work_with = source[begin_from..end_at]
	    else
	      work_with = [ source[line-1] ]
	    end
	    work_with ||= []
	    res = []
	    work_with.each do |i, l|
	      l = ('<span class="hl_lineno">%.3d:</span>%s' % [i,"  "]) + l
	      if i == line and mark_line
	        buf = '<div class="current_line">' + l + '</div>'
	      else
	        buf = l + "\n"
	      end
	      res << buf
	    end
	    res.join
	  end
	  ###################################################
	
	  ###################################################
	  def hilite_source(src)
	    lx = LexerRuby::LexerOld.new
	    src.each do |sline|
	      lx.lex_line(sline)
	    end
	    res = []
	    lineno = 0
	    this_line = []
	    hc = false
	    heredoc_buf = nil
	    lx.result.each do |text, token|
	      if hc
	        lineno += 1
	        res << [lineno, this_line.join]        
	        this_line = []
	        hc = false
	      end
	      if token != :heredoc and heredoc_buf and token != :any
	        heredoc = heredoc_buf.split(/\n/)
	        heredoc.each do |hd_line|
	          res << [lineno, ('<span class="hl_heredoc">%s</span>' % [hd_line.to_s])]
	          lineno += 1
	        end
	        this_line = []
	        heredoc_buf = nil
	      end
	      case token
	        when :keyword, :ident, :punct, 
	              :comment, :ivar, :dot, 
	              :string, :command, :number,
	              :gvar, :literal, :symbol
	          if token == :comment
	            hc = true
	          end
	          text = Iowa::Util.escapeHTML(text)
	          this_line << ('<span class="hl_%s">%s</span>' % [token.to_s, text.rstrip])
	        when :heredoc
	          text = Iowa::Util.escapeHTML(text)
	          heredoc_buf ||= ''
	          heredoc_buf << text
	        when :any
	          if text =~ /^\s*\n$/
	            lineno += 1
	            res << [lineno, this_line.join]
	            this_line = []
	          else
	            this_line << text
	          end
	        else
	          this_line << Iowa::Util.escapeHTML(text)
	        end
	    end
	    res << [lineno+1, this_line.join] if this_line.length > 0
	    res
	  end
	  ###################################################
	    
	  ###################################################
	  def print
	    tpl = build_template
	    contents = {}
	    contents['message'] = Iowa::Util::escapeHTML(@exception.message).to_s
	    contents['exception'] = @exception.class.name
	    contents['time'] = Time.now.to_s
	    bt = []
	    @exception.backtrace.each_with_index do |str,idx| 
	      file,text = str.scan(/^(.+):(.+)(?::(.+))?$/).flatten;
	      file,line = file.split(/:/)
	      unless line
	        line = text
	        text = nil
	      end
	      is_stdlib = false
	      paths = [RbConfig::CONFIG['rubylibdir'], RbConfig::CONFIG['sitedir']]
	      paths.each do |dir| 
	        is_stdlib = true if (file =~ /#{Regexp::escape(dir)}/)
	      end
	      data = { 'file' => file, 'line' => line, 'text' => text, 'from_stdlib' => false}
	      if idx == 0
	        data['source'] = file == '(eval)' ? '' : gen_source(file, line)
	      else
	        data['source'] = file == '(eval)' ? '' : gen_source(file, line)
	      end
	      data['iteration_id'] = idx.to_s
	      bt << data
	    end
	    contents['backtrace'] = bt
	    tpl.write_html_on(output='', contents)
	    output
	  end
	  ###################################################
	  
	  alias_method :to_s, :print
	  
	end
end

class LexerBase
	def initialize
		@states = []
		@result = []
		@result_endofline = nil
	end
	attr_reader :states, :result, :result_endofline

	def set_states(states)
		@states = states
	end
	def set_result(result)
		@result = result
	end
	def format(text, state_output)
		@result << [text, state_output]
	end
	def format_end(state_output)
		@result_endofline = state_output
	end
	def match(regexp, output)
		m = regexp.match(@text)
		return false unless m
		txt = @text.slice!(0, m.end(0))
		format(txt, output)
		true
	end
	def lex_line(text)
		raise "derived class #{self.class} must overload #lex_line."
	end
	def self.profile
		lines = IO.readlines(__FILE__)
		lexer = self.new
		puts "profiling the #{self.inspect} lexer (this may take some time)"
		require 'profiler'
		Profiler__.start_profile
		lines.each do |line|
			lexer.set_states([])
			lexer.set_result([])
			lexer.lex_line(line)
		end
		Profiler__.print_profile(STDOUT)
	end
	def self.benchmark
		n = 10000
		puts "benchmarking the lexers (computing #{n} lines " +
			"with GC disabled)"
		require 'benchmark'
		Benchmark.bm(20) do |b|
			lexer = LexerRuby::LexerOld.new
#=begin
			lines = IO.readlines(__FILE__)
			GC.disable
			b.report("#{lexer.class}") do
				n.times do |i|
					lexer.set_states([])
					lexer.set_result([])
					lexer.lex_line(lines[i%lines.size].clone)
				end
			end
#=begin
			GC.enable
			GC.start
			lines = IO.readlines(__FILE__)
			lexer = LexerRuby::LexerNew.new
			GC.disable
			b.report("#{lexer.class}") do
				n.times do |i|
					lexer.set_states([])
					lexer.set_result([])
					lexer.lex_line(lines[i%lines.size])
				end
			end
=begin
=end
			GC.enable
			GC.start
			lines = IO.readlines(__FILE__)
			lexer = LexerRuby::Lexer3.new
			GC.disable
			b.report("#{lexer.class}") do
				n.times do |i|
					lexer.set_states([])
					lexer.set_result([])
					lexer.lex_line(lines[i%lines.size])
				end
			end
			GC.enable
		end
	end
end

module LexerText

class Lexer < LexerBase
	RE_TAB = /\A\t+/  
	RE_NOTTAB = /\A[^\t]+/  
	def lex_line(text)
		@text = text
		until @text.empty?
			if match(RE_TAB, :tab)
			else
				match(RE_NOTTAB, :text)
			end
		end
	end
end # class Lexer

end # module LexerText

module LexerRuby

module State

class Base
end

class Heredoc < Base
	def initialize(begin_tag, ignore_leading_spaces, interpolate=true)
		@begin_tag = begin_tag
		@ignore_leading_spaces = ignore_leading_spaces
		@interpolate = interpolate
	end
	attr_reader :begin_tag, :ignore_leading_spaces, :interpolate
	def ==(other)
		(self.class == other.class) and
		(@begin_tag == other.begin_tag) and 
		(@ignore_leading_spaces == other.ignore_leading_spaces) and
		(@interpolate == other.interpolate)
	end
end

class Comment < Base
	def ==(other)
		(self.class == other.class)
	end
end

class Endoffile < Base
	def ==(other)
		(self.class == other.class)
	end
end

end # module State

class NewerRubyLexer
	RE_TOKENIZE = Regexp.new([
		# TODO: @ivar
		# TODO: @@cvar
		# TODO: $gvar
		# TODO: %literals  %w(a b c)  %Q|'"|
		# TODO: :symbol
		# TODO: ?x  chars
		# TODO: 0b01001  binary data
		# TODO: 0x234af  hex data
		# TODO: keywords  =begin  defined?
		# TODO: ruby puncturation  ..  ...  &&  ||
		# TODO: /regexp/
		# TODO: __END__ tag
		# TODO: illegal ruby heredoc which has space after end-tag
		# TODO: illegal ruby puncturation  &&&  ||| 
		# TODO: illegal ruby numbers  0x23Yab
		'#.*',                        # # blah  ## !?!  comment
		'<<-?[[:alpha:]]+',           # <<HTML  <<-XML  heredoc
		'<<-?\'[[:alpha:]]+\'',       # <<'eof' <<-'X'  heredoc single quoted
		'<<-?"[[:alpha:]]+"',         # <<"eof" <<-"X"  heredoc double quoted
		'\.[[:alpha:]][[:alnum:]_]*', # .method .dup2   method call
		'[[:alpha:]][[:alnum:]_]*',   # value   pix2_3  identifier
		'\'(?:[^\\\\]|\\\\.)*?\'',    # '\'x\\' ''      string single quoted
		'"(?:[^\\\\]|\\\\.)*?"',      # "ab"    ""      string double quoted
		'\d+\.\d+',                   # 0.123   32.10   number as float
		'\d+',                        # 42      999     number as integer
		'.'                           # *       +       fallthrough
	].join('|'))
	def initialize
		@char_to_symbol_hash = {
			" "  => :space,
			"\t" => :tab
		}
		@char_to_symbol_hash.default = :should_not_happen
	end
	def tokenize(string)
		string.scan(RE_TOKENIZE)
	end
	def lex(string)
		tokens = tokenize(string)
		states = tokens.map do |token|
			# TODO: by inserting 2 parentesises in the TOKENIZER
			# then I can destinguish between good/bad tokens.
			# 'ab'.scan(/(a)(b)/) do |(good, bad)|
			case token
			when /\A(?:"|')./
				:string
			when /\A<<-?(?:"|'|)[[:alpha:]]/
				:heredoc
			when /\A\.[[:alpha:]]/
				:method
			when /\A[[:alpha:]]/
				:ident
			when /\A#/
				:comment
			when /\A[[:punct:]]/
				:punct
			when /\A[[:digit:]]/
				:number
			else
				@char_to_symbol_hash[token]
			end
		end
		[tokens, states]
	end
end

class Lexer3 < LexerBase
	def initialize
		@rl = NewerRubyLexer.new
		super
	end
	def what_to_output(hash)
		@rl.what_to_output(hash)
	end
	def lex_line(text)
		tokens, states = @rl.lex(text)
		tokens.each_with_index do |token, index|
			format(token, states[index])
		end
		true
	end
end


class RubyLexer
	def initialize
		@result = []
	end
	attr_reader :result
	PUNCT = ['(', ')'] + 
		%w(=== ==  =~  =>  =   !=  !~  !) +
		%w(<<  <=> <=  <   >=  >) +
		%w({   }   [   ]) +
		%w(::  :   ... ..) +
		%w(+=  +   -=  -   **  *   /   %) +
		%w(||  |   &&  &) +
		%w(,   ;) 
	RE_NUMBER = /\d[\d\.]*/
	RE_PUNCT = Regexp.new('(?:' + 
		PUNCT.map{|i| Regexp.escape(i)}.join('|') + ')')
	RE_IDENT = /[[:alpha:]][\w\!]*/
	RE_STRING = /".*?"|'.*?'/
	RE_COMMENT = /#.*/
	RE_COMMAND = /\.[[:alnum:]_]*[[:alnum:]_\?\!]/
	RE_SPACE = /\x20+/
	RE_NEWLINE = /\n+/
	RE_TABS = /\t+/
	def scan_index(string, regexp, prio, symbol)
		string.scan(regexp) do
			@result << [$~.begin(0), prio, $~.end(0), symbol]
		end
	end
	def lex(string)
		scan_index(string, RE_COMMENT, 0, :comment)
		scan_index(string, RE_STRING, 1, :string)
		scan_index(string, RE_COMMAND, 2, :command)
		scan_index(string, RE_IDENT, 3, :ident)
		scan_index(string, RE_NUMBER, 4, :number)
		scan_index(string, RE_PUNCT, 5, :punct)
		scan_index(string, RE_SPACE, 6, :space)
		scan_index(string, RE_NEWLINE, 7, :newline)
		scan_index(string, RE_TABS, 8, :tabs)
	end

	remove_method(:result)
	def result
		# primary key = string begin position
		# secondary key = priority
		@result.sort!
		# collect the highest precedens data
		ary = [0]
		@result.each do |i1, prio, i2, symbol|
			next if ary.last > i1 # discard low precedens data
			if ary.last < i1
				ary << :any
				ary << i1
			end
			ary << symbol
			ary << i2
		end
		#p ary
		ary
	end
	def self.mk(*symbols)
		symbols.each do |symbol|
			class_eval %{
				def #{symbol.to_s}
					res = []
					@result.each do |i1, prio, i2, sym|
						if sym == :#{symbol.to_s}
							res << [i1, i2]
						end
					end
					res
				end
			}
		end
	end
	mk :number, :ident, :string, :punct 
	mk :comment, :command, :space, :newline, :tabs
end

class LexerNew < LexerBase
	def lex_line(text)
		#puts("-"*40)
		#puts "text=#{text.inspect}"
		rl = RubyLexer.new
		rl.lex(text)
		res = rl.result
		#puts "res=#{res.inspect}"
		i1 = res.shift
		while res.size > 1
			symbol = res.shift
			i2 = res.shift
			format(text[i1, (i2-i1)], symbol)
			i1 = i2
		end
		#puts "result=#{@result.inspect}"
		true
	end
end

class LexerOld < LexerBase
	RE_COMMENT = /^#.*/m  

	RE_TAB = /^\t+/  

	RE_SPACE = /^\x20+/  

	KEYWORDS = %w(alias and begin BEGIN break case class) +
		%w(defined? def do else elsif end END ensure for if loop) +
		%w(module next nil not or raise redo require rescue) +
		%w(retry return self super then true false undef) +
		%w(unless until yield when while)
	RE_KEYWORD = Regexp.new(
		'\A(?:' +
		KEYWORDS.map{|txt|Regexp.escape(txt)}.join('|') + 
		')(?!\w)'
	)

	RE_SYMBOL = /\A:[[:alpha:]_][[:alnum:]_]*/

	RE_STRING = /^("|\')(?:[^\\]|\\.)*?\1/
	RE_STRING_INTERPOL = /\A   ((?:[^\\]|\\.)*?)   (\#\{ .*? \}) /x
	# TODO: interpolated code can nest (hint: recursion is necessary)
	def match_string
		m = RE_STRING.match(@text)
		return false unless m
		txt = @text.slice!(0, m.end(0))
		if m[1] == '\''
			format(txt, :string)
			return true
		end
		# double quoted strings may contain interpolated code
		until txt.empty?
			m = RE_STRING_INTERPOL.match(txt)
			unless m
				format(txt, :string)
				break
			end
			format(m[1], :string) unless m[1].empty?
			format(m[2], :string1)
			txt.slice!(0, m.end(0))
		end
		true
	end

	RE_REGEXP = /\A\/(.*?[^\\])?\//
	
	RE_IVAR = /\A@[[:alnum:]_]+/  

	RE_DOT = /\A\.[[:alnum:]_]*[[:alnum:]_\?\!]/

	RE_IDENTIFIER = /\A(?:[[:alnum:]_]+|\S+)/

	RE_NUMBER = Regexp.new(
		'\A(?:' + [
			'0x[_a-fA-F0-9]+',
			'0b[_01]+',
			'\d[0-9_]*(?:\.[0-9_]*)?',
			'\?.'
		].join('|') + 
		')'
	)

	PUNCT = ['(', ')'] + 
		%w(=== ==  =~  =>  =   !=  !~  !) +
		%w(<<  <=> <=  <   >=  >) +
		%w({   }   [   ]) +
		%w(::  :   ... ..) +
		%w(+=  +   -=  -   **  *   /   %) +
		%w(||  |   &&  &) +
		%w(,   ;) 
	RE_PUNCT = Regexp.new(
		'\A(?:' + 
		PUNCT.map{|txt|Regexp.escape(txt)}.join('|') + 
		')'
	)

	VAR_GLOBALS = %q(_~*$!@/\\;,.=:<>"-&`'+1234567890).split(//)
	RE_GVAR = Regexp.new(
		'\A\$(?:' +
		VAR_GLOBALS.map{|txt|Regexp.escape(txt)}.join('|') +  
		'|[[:alnum:]_]+' +
		')'
	)

	# TODO: deal with multiline literals
	RE_LITERAL = Regexp.new(
		'\A%[Qqwrx]?(?:' + [
		'\(.*?\)',   # TODO: must count pairs
		'\{.*?\}',   # TODO: must count pairs
		'\<.*?\>',   # TODO: must count pairs
		'\[.*?\]',   # TODO: must count pairs
		'([^\(\{\<\[]).*?\1'
		].join('|') + ')'
	)

	RE_BEGIN = /\A=begin$\n?\x20*\z/   # eat tailing space
	def match_comment_begin
		m = RE_BEGIN.match(@text)
		return false unless m
		#puts "comments"
		@states << State::Comment.new
		txt = @text.slice!(0, m.end(0))
		format(txt, :mcomment)
		format_end(:mcomment_end)
		true
	end 
	RE_HEREDOC = /\A<<(-)?('|"|)(\w+)\2/
	def match_heredoc_begin
		m = RE_HEREDOC.match(@text)
		return false unless m
		ignore_leading_space = (!m[1].nil?)
		interpolate = (m[2] != "'")
		begin_pattern = m[3]
		@states << State::Heredoc.new(
			begin_pattern, 
			ignore_leading_space,
			interpolate
		)
		txt = @text.slice!(0, m.end(0))
		format(txt, :heredoc)
		true
	end
	RE_END = /\A__END__$\n?\x20*\z/   # eat tailing space 
	def match_endoffile
		m = RE_END.match(@text)
		return false unless m
		#puts "propagate __END__"
		@states << State::Endoffile.new
		txt = @text.slice!(0, m.end(0))
		format(txt, :endoffile)
		format_end(:endoffile_end)
		true
	end
	def lex_line_normal(text)
		@text = text
		return if match_comment_begin
		return if match_endoffile
		until @text.empty?
			if match(RE_COMMENT, :comment)
				format_end(:comment_end)
			elsif match(RE_REGEXP, :regexp)
			elsif match_heredoc_begin
			elsif match(RE_LITERAL, :literal)
            elsif match(RE_KEYWORD, :keyword)			
			elsif match(RE_SYMBOL, :symbol)
			elsif match(RE_PUNCT, :punct)
			elsif match(RE_GVAR, :gvar)
			elsif match_string
			elsif match(RE_NUMBER, :number)
			elsif match(RE_IVAR, :ivar)
			elsif match(RE_DOT, :dot)
			elsif match(RE_IDENTIFIER, :ident)
			elsif match(RE_TAB, :tab)
			elsif match(RE_SPACE, :space)
			else 
				#@text.slice!(0, 1)
				txt = @text.slice!(0, 1)
				format(txt, :any)
			end
		end
	end
	def match_heredoc_end(regexp)
		m = regexp.match(@text)
		return false unless m
		#puts "end of heredoc"
		@states.shift
		txt = @text.slice!(0, m.end(0))
		format(txt, :heredoc)
		format_end(:heredoc_end2)
		true
	end
	def lex_line_heredoc(text)
		# TODO: color interpolated code  #{code}
		@text = text
		format_end(:heredoc_end)
		hd_end = nil
		state = @states[0]
		hd_end = /\A#{state.begin_tag}$\n?\x20*\z/
		return if match_heredoc_end(hd_end)
		# continue lexing
		ign_lead_spc = state.ignore_leading_spaces
		until @text.empty?
			if match(RE_TAB, :heredoc_tab)
			elsif ign_lead_spc and match_heredoc_end(hd_end)
			else
				txt = @text.slice!(0, 1)
				format(txt, :heredoc)
			end
		end
	end
	def match_comment_end
		m = /\A\=end\b.*?$\n?\x20*\z/.match(@text)
		return false unless m
		#puts "comment end"
		@states.shift
		txt = @text.slice!(0, m.end(0))
		format(txt, :mcomment)
		true
	end
	def lex_line_comment(text)
		@text = text
		format_end(:mcomment_end)
		return if match_comment_end
		until @text.empty?
			if match(RE_TAB, :mcomment_tab)
			else
				txt = @text.slice!(0, 1)
				format(txt, :mcomment)
			end
		end
	end
	def lex_line_endoffile(text)
		@text = text
		format_end(:endoffile_end)
		until @text.empty?
			if match(RE_TAB, :endoffile_tab)
			else
				txt = @text.slice!(0, 1)
				format(txt, :endoffile)
			end
		end
	end
	def lex_line(text)
		if @states.empty? 
			return lex_line_normal(text) 
		end
		state = @states[0]
		case state
		when State::Heredoc
			 lex_line_heredoc(text)
		when State::Comment
			 lex_line_comment(text)
		when State::Endoffile
			 lex_line_endoffile(text)
		else
			raise "unknown state #{state.class}"
		end
	end
end

# TODO: make the new lexer work!
Lexer = LexerOld  # slow
#Lexer = LexerNew  # slow
#Lexer = Lexer3     # fastest

end # module LexerRuby

__END__
<html>
  <head>
    <title>Oops!</title>
    <style>
    .data { 
      border-style: dotted; 
      padding: 4px; }
    .trace_header { 
      border-style: dotted; 
      border-width: thin; 
      background-color: #CCCCCC; 
      text-align: center; }
    .normal_trace_entry {
      border-style: dotted; 
      border-width: thin; 
      text-align: center; 
      padding: 6px; }
    .stdlib_trace_entry {
      border-style: dotted; 
      border-width: thin; 
      text-align: right; 
      padding: 6px; } 
    .source {
      width: 100%;
      background-color: #F4F4F4;
      display: none;
    }
    span.hl_lineno {
      font-weight: bold;
    }    
    pre {
    	width: 80%;
    	padding: 0px;
    	margin: 0px;
    }
    div.current_line {
      color: red;
      background-color: #F4DADA;
    }
    span.hl_keyword {
    	font-weight: bold;
    }
    span.hl_punct {
    	font-weight: bold;
    	color: darkblue;
    }
    span.hl_ident {
    }
    span.hl_command {
    	font-weight: bold;
    }
    span.hl_number {
    	color: darkgreen;
    }
    span.hl_string {
    	color: darkgreen;
    }    
    span.hl_comment {
    	color: grey;
    }
    span.hl_ivar {
    	font-weight: bold;
    	color: darkred;
    }
    span.hl_dot {
    	font-weight: bold;
    }
    span.hl_literal {
    	color: green;
    }
    span.hl_gvar {
    	font-weight: bold;
    }
    span.hl_symbol {
    	color: blue;
    }
    span.hl_regexp {
    	color: green;
    }
    tr {
    	background-color: white;
    }
    </style>  
<script type="text/javascript"  language="javascript">
	function toggleCode( id ) {
		if ( document.getElementById )
			elem = document.getElementById( id );
		else if ( document.all )
			elem = eval( "document.all." + id );
		else
			return false;

		elemStyle = elem.style;
		
		if ( elemStyle.display != "block" ) {
			elemStyle.display = "block"
		} else {
			elemStyle.display = "none"
		}

		return true;
	}

    var isDOM      = (typeof(document.getElementsByTagName) != 'undefined'
                      && typeof(document.createElement) != 'undefined')
                   ? 1 : 0;
    var isIE4      = (typeof(document.all) != 'undefined'
                      && parseInt(navigator.appVersion) >= 4)
                   ? 1 : 0;
    var isNS4      = (typeof(document.layers) != 'undefined')
                   ? 1 : 0;
    var capable    = (isDOM || isIE4 || isNS4)
                   ? 1 : 0;
    // Uggly fix for Opera and Konqueror 2.2 that are half DOM compliant
    if (capable) {
        if (typeof(window.opera) != 'undefined') {
            var browserName = ' ' + navigator.userAgent.toLowerCase();
            if ((browserName.indexOf('konqueror 7') == 0)) {
                capable = 0;
            }
        } else if (typeof(navigator.userAgent) != 'undefined') {
            var browserName = ' ' + navigator.userAgent.toLowerCase();
            if ((browserName.indexOf('konqueror') > 0) && (browserName.indexOf('konqueror/3') == 0)) {
                capable = 0;
            }
        } // end if... else if...
    } // end if
    
    /**
 * This array is used to remember mark status of rows in browse mode
 */
var marked_row = new Array;


/**
 * Sets/unsets the pointer and marker in browse mode
 *
 * @param   object    the table row
 * @param   integer  the row number
 * @param   string    the action calling this script (over, out or click)
 * @param   string    the default background color
 * @param   string    the color to use for mouseover
 * @param   string    the color to use for marking a row
 *
 * @return  boolean  whether pointer is set or not
 */
function setPointer(theRow, theRowNum, theAction, theDefaultColor, thePointerColor, theMarkColor)
{
    var theCells = null;

    // 1. Pointer and mark feature are disabled or the browser can't get the
    //    row -> exits
    if ((thePointerColor == '' && theMarkColor == '')
        || typeof(theRow.style) == 'undefined') {
        return false;
    }

    // 2. Gets the current row and exits if the browser can't get it
    if (typeof(document.getElementsByTagName) != 'undefined') {
        theCells = theRow.getElementsByTagName('td');
    }
    else if (typeof(theRow.cells) != 'undefined') {
        theCells = theRow.cells;
    }
    else {
        return false;
    }

    // 3. Gets the current color...
    var rowCellsCnt  = theCells.length;
    var domDetect    = null;
    var currentColor = null;
    var newColor     = null;
    // 3.1 ... with DOM compatible browsers except Opera that does not return
    //         valid values with "getAttribute"
    if (typeof(window.opera) == 'undefined'
        && typeof(theCells[0].getAttribute) != 'undefined') {
        currentColor = theCells[0].getAttribute('bgcolor');
        domDetect    = true;
    }
    // 3.2 ... with other browsers
    else {
        currentColor = theCells[0].style.backgroundColor;
        domDetect    = false;
    } // end 3

    // 3.3 ... Opera changes colors set via HTML to rgb(r,g,b) format so fix it
    if (currentColor.indexOf("rgb") >= 0)
    {
        var rgbStr = currentColor.slice(currentColor.indexOf('(') + 1,
                                     currentColor.indexOf(')'));
        var rgbValues = rgbStr.split(",");
        currentColor = "#";
        var hexChars = "0123456789ABCDEF";
        for (var i = 0; i < 3; i++)
        {
            var v = rgbValues[i].valueOf();
            currentColor += hexChars.charAt(v/16) + hexChars.charAt(v%16);
        }
    }

    // 4. Defines the new color
    // 4.1 Current color is the default one
    if (currentColor == ''
        || currentColor.toLowerCase() == theDefaultColor.toLowerCase()) {
        if (theAction == 'over' && thePointerColor != '') {
            newColor              = thePointerColor;
        }
        else if (theAction == 'click' && theMarkColor != '') {
            newColor              = theMarkColor;
            marked_row[theRowNum] = true;
            // Garvin: deactivated onclick marking of the checkbox because it's also executed
            // when an action (like edit/delete) on a single item is performed. Then the checkbox
            // would get deactived, even though we need it activated. Maybe there is a way
            // to detect if the row was clicked, and not an item therein...
            // document.getElementById('id_rows_to_delete' + theRowNum).checked = true;
        }
    }
    // 4.1.2 Current color is the pointer one
    else if (currentColor.toLowerCase() == thePointerColor.toLowerCase()
             && (typeof(marked_row[theRowNum]) == 'undefined' || !marked_row[theRowNum])) {
        if (theAction == 'out') {
            newColor              = theDefaultColor;
        }
        else if (theAction == 'click' && theMarkColor != '') {
            newColor              = theMarkColor;
            marked_row[theRowNum] = true;
            // document.getElementById('id_rows_to_delete' + theRowNum).checked = true;
        }
    }
    // 4.1.3 Current color is the marker one
    else if (currentColor.toLowerCase() == theMarkColor.toLowerCase()) {
        if (theAction == 'click') {
            newColor              = (thePointerColor != '')
                                  ? thePointerColor
                                  : theDefaultColor;
            marked_row[theRowNum] = (typeof(marked_row[theRowNum]) == 'undefined' || !marked_row[theRowNum])
                                  ? true
                                  : null;
            // document.getElementById('id_rows_to_delete' + theRowNum).checked = false;
        }
    } // end 4

    // 5. Sets the new color...
    if (newColor) {
        var c = null;
        // 5.1 ... with DOM compatible browsers except Opera
        if (domDetect) {
            for (c = 0; c < rowCellsCnt; c++) {
                theCells[c].setAttribute('bgcolor', newColor, 0);
            } // end for
        }
        // 5.2 ... with other browsers
        else {
            for (c = 0; c < rowCellsCnt; c++) {
                theCells[c].style.backgroundColor = newColor;
            }
        }
    } // end 5

    return true;
} // end of the 'setPointer()' function
    
    
 /**
 * getElement
 */
function getElement(e,f){
    if(document.layers){
        f=(f)?f:self;
        if(f.document.layers[e]) {
            return f.document.layers[e];
        }
        for(W=0;i<f.document.layers.length;W++) {
            return(getElement(e,fdocument.layers[W]));
        }
    }
    if(document.all) {
        return document.all[e];
    }
    return document.getElementById(e);
}
 </script>    
  </head>
  <body bgcolor="white">
    <table cellspacing="4" width ="80%" align="center">
      <tr>
        <td colspan="3" align="left" class="normal_trace_entry">
            <p class="data" style="font-size: large; margin: 0px; border-color: red;"><b>Exception raised!</b><br />          
              <b>%exception%</b>: <b>%message%</b><br />
              Time: <b>%time%</b>
            </p>
        </td>
      </tr>
      <tr>
        <td class="trace_header"><b>File</b></td>
        <td class="trace_header"><b>Line</b></td>
        <td class="trace_header"><b>Info</b></td>
      </tr>
START:backtrace
IFNOT:from_stdlib
      <tr bgcolor="white" onmouseover="setPointer(this, %iteration_id%, 'over', 'white', '#CCFFCC', '#FFB2B2');"  onmouseout="setPointer(this, %iteration_id%, 'out', 'white', '#CCFFCC', '#FFB2B2');"  onmousedown="toggleCode('src%iteration_id%'); setPointer(this, %iteration_id%, 'click', 'white', '#CCFFCC', '#FFB2B2');">
IF:text
        <td bgcolor="white" class="normal_trace_entry">%file%</td>
        <td bgcolor="white" class="normal_trace_entry">%line%</td>
        <td bgcolor="white" class="normal_trace_entry">%text%</td>
ENDIF:text
IFNOT:text
        <td bgcolor="white" class="normal_trace_entry">%file%</td>
        <td bgcolor="white" class="normal_trace_entry" colspan="2">%line%</td>  
ENDIF:text
IF:source
    	</tr>
    	<tr> 
    		<td colspan="3"><div id="src%iteration_id%" class="source"><tt><pre>%source%</pre></tt></div></td>
ENDIF:source
ENDIF:from_stdlib
IF:from_stdlib
      <tr bgcolor="white" onmouseover="setPointer(this, %iteration_id%, 'over', 'white', '#CCFFCC', '#FFB2B2');"  onmouseout="setPointer(this, %iteration_id%, 'out', 'white', '#CCFFCC', '#FFB2B2');"  onmousedown="setPointer(this, %iteration_id%, 'click', 'white', '#CCFFCC', '#FFB2B2');">
IF:text
        <td bgcolor="white" class="stdlib_trace_entry">%file%</td>
        <td bgcolor="white" class="stdlib_trace_entry">%line%</td>
        <td bgcolor="white" class="stdlib_trace_entry">%text%</td>
ENDIF:text
IFNOT:text
        <td bgcolor="white" class="stdlib_trace_entry">%file%</td>
        <td bgcolor="white" class="stdlib_trace_entry" colspan="2">%line%</td>  
ENDIF:text
ENDIF:from_stdlib
      </tr>
      
END:backtrace
    </table>
  </body>
</html>
