require 'iowa/LinkedList'
require 'iowa/caches/LRUCache'
require 'thread'

class Numeric
	def px;Iowa::CSS::PX.new(self);end
	def pt;Iowa::CSS::PT.new(self);end
	def em;Iowa::CSS::EM.new(self);end
	def in;Iowa::CSS::IN.new(self);end
	def mm;Iowa::CSS::MM.new(self);end
	def pct;Iowa::CSS::PCT.new(self);end
end

module Iowa

	# Iowa::CSS implements a CSS DSL in Ruby.  It tries to stick as
	# closely to CSS syntax as it can, so that any learning curve is
	# minimized.
	
	class CSS
		undef :p
		undef :display

		C0 = '0'.freeze unless const_defined?(:C0)
		C1 = '1'.freeze unless const_defined?(:C1)
		C_slash = '/'.freeze unless const_defined?(:C_slash)

		# Any of the attributes in this list are fat attributes.  A fat
		# attribute is one can can take multiple modifiers (such as
		# font-color, font-size, font-weight, etc...) in a block.
		#
		# font {
		#   color 'green'
		#   size 12.px
		# }
		
		FatAttributeList = {
			:background => true, 
			:border => true,
			:font => true,
			:list => true,
			:list_style => true,
			:margin => true,
			:outline => true,
			:padding => true,
			:text => true
		} unless const_defined?(:FatAttributeList)
		
		# This Iowa::LinkedList subclass fine tunes the iteration order, the
		# to_s generation, and allows missing methods to be handled so that it
		# will work to store CSS items defined by the DSL.
		
		class CSSList < Iowa::LinkedList
			undef :display

			# Reverses the iteration order from the regular LinkedList.
			def each
				n = @tail
				while (n = n.prev_node) and n != @head
					yield(n.key,n.value)
				end
			end

			# Generates a string representation of the CSSList.

			def to_s
				r = ''
				each do |key, value|
					r << value.to_s
				end
				r
			end
			
			# method_missing is handled to allow setting arbitrary attributes.

			def method_missing(key,*args)
				if args.length > 0
					self[key] = args.first
				else
					self[key].value
				end
			end
		end

		# Simple class to represent a conditional fingerprint.
		
		class Fingerprint
			def initialize(fingerprint)
				@fingerprint = fingerprint
			end

			def fingerprint=(val)
				@fingerprint = val
			end

			def fingerprint
				@fingerprint
			end

			def to_s
				@fingerprint.to_s
			end
		end

		# A Condition is used to implement an if/then/else replacement for the
		# CSS DSL.  The replacement allows the system to remember the
		# conditions so that they can be checked later without executing all
		# of the statements in the code.
		
		class Condition < CSSList
			attr_accessor :next_condition

			def initialize(condition, context = nil, parent = nil, skip = false)
				@condition = condition
				@context = context
				@skip = skip
				@result = condition.call(context)
				parent.next_condition = self if parent
				super()
			end

			def then(&blk)
				if !@skip and @result
					t = []
					eval("lambda {|x| x.replace [@output]}",blk).call(t)
					output = t.first
					parent = output.last
					yield
				end
				self
			end

			def elsif(&condition)
				Condition.new(condition,@context,self,@result)
			end

			def else(fp = C1, &blk)
				# This lets one specify a fingerprint for an else. 
				condition = lambda {|context| fp}
				Condition.new(condition,@context,self,@result)
				# and then handle it...
				if !@skip and !@result
					t = []
					eval("lambda {|x| x.replace [@output]}",blk).call(t)
					output = t.first
					parent = output.last
					yield
				end
			end

			def fingerprint(context = nil)
				fp = (_ = @condition.call(context)) ?
					(_.is_a?(Fingerprint) ? [_] : [C1]) :
					[C0]
				fp += next_condition.fingerprint(context) if next_condition
				fp
			end

			def to_s(prefix = nil)
				super()
			end
		end

		class Selector < CSSList

			def self.method_missing(ctype,*args,&blk)
				t = []
				if blk
					eval("lambda {|x| x.replace [@output]}",blk).call(t)
					output = t.first
					parent = output.last
					obj = self.new(ctype,*args)
					parent.push obj
					output.push obj
					yield
					output.pop
				else
					self.new(ctype,*args)
				end
			end
			
			def initialize(selector,*args)
				@selector = selector == :_ ? '' : selector
				@suffix = ''
				
				args.each do |arg|
					process_selector_option(arg,@suffix)
				end

				super()
			end

			def process_selector_option(arg,buffer)
				if arg.is_a?(::Symbol)
					buffer << ":#{arg}"
				elsif arg.is_a?(::Hash)
					arg.each do |k,v|
						if k == :lang
							buffer << ":lang(#{v})"
						elsif k == :not
							buffer << ":not("
							process_selector_option(v,buffer)
							buffer << ")"
						end
					end
				elsif arg.is_a?(::Array)
					arg.each do |v|
						process_selector_option(v,buffer)
					end
				else
					buffer << "[#{arg}]"
				end
			end

			def token
				' '
			end

			def separator
				''
			end
			
			def to_s(prefix = '')
				r = ''
				section = ''
				ws = prefix.match(/^(\s*)/)[1]
				each do |key,value|
					section << "#{value.to_s("#{ws}  ")}" if value.respond_to?(:is_attribute?)
				end
				tok = (prefix =~ /^\s*$/ and token == ' ') ? '' : token
				if section != ''
					r << "#{prefix}#{tok}#{@selector}#{@suffix} {\n#{section}#{ws}}\n"
				end
				each do |key,value|
					r << value.to_s("#{prefix}#{tok}#{@selector}#{@suffix}#{separator}") unless value.respond_to?(:is_attribute?)
				end
				r
			end

			def url(u)
				"url(\"#{u}\")"
			end

		end

		class Tag < Selector; end

		class Pseudo < Selector
			def token
				':'
			end

			def separator
				''
			end	
		end

		class Literal_
			def initialize(text)
				@text = text
			end

			def to_s(prefix = '')
				@text
			end
		end

		class Class < Selector
			def token
				'.'
			end
			
			def separator
				' '
			end
		end
		
		class Id < Selector
			def token
				'#'
			end
			
			def separator
				' '
			end
		end
		
		class Child < Selector
			def token
				' > '
			end

			def separator
				''
			end
		end

		class Adjacent < Selector
			def token
				' + '
			end

			def separator
				''
			end
		end

		class Indirect < Selector
			def token
				' ~ '
			end

			def separator
				''
			end
		end

		class Attribute
			attr_accessor :key, :value

			def is_attribute?; true; end
				
			def initialize(k = '', v = '')
				@key = k
				@value = v
			end

			def []=(k,v)
				@key = k
				@value = v
			end

			def to_s(ws = '')
				"#{ws}#{CSS::correct_for_css(@key)}: #{CSS::correct_for_css(@value)};\n"
			end
		end

		class FatAttribute < CSSList

			def is_attribute?; true; end
			
			def initialize(atype)
				@prefix = atype.to_s.downcase.intern
				super()
			end

			def method_missing(meth,*args)
				if args.empty?
					self[meth].value
				else
					self[meth.to_s.sub('=','').intern] = args.length > 1 ? args : args.first
				end
			end

			def to_s(ws = '')
				r = ''
				each do |k,v|
					r << "#{ws}#{CSS::correct_for_css(@prefix)}-#{CSS::correct_for_css(k)}: #{CSS::correct_for_css(v.value)};\n"
				end
				r
			end
		end

		class ApplesAndOrangesException < Exception; end

		class Units
			def to_f
				@value
			end

			def initialize(v)
				@value = v.to_f
			end

			def unit
				@unit ||= self.class.name.split('::').last.downcase
			end
			
			def to_s
				"#{@value}#{unit}"
			end

			def method_missing(meth,*args)
				if args.detect {|a| (self.class != a.class and MutuallyExclusiveUnits.include?(a.class))}
					raise ApplesAndOrangesException
				else
					r = @value.send(meth,*args)
					r.is_a?(::Float) ? self.class.new(r) : r
				end
			end
		end

		class PX < Units; end
		class PT < Units; end
		class EM < Units; end
		class IN < Units; end
		class MM < Units; end
		class PCT < Units
			def to_s
				"#{@value}%"
			end
		end

		MutuallyExclusiveUnits = [PX,PT,EM,IN,MM,PCT]

		
		attr_accessor :output

		def initialize(css = nil,with_cache = false)
			@mutex = Mutex.new
			@output = [CSSList.new]
			@conditions = []
			if with_cache
				initialize_cache(with_cache == true ? {:maxsize => 10} : with_cache)
			else
				@cache = nil
			end
			@css = css
		end

		def initialize_cache(*args)
			@cache = Iowa::Caches::LRUCache.new(*args)
		end

		def clear_output
			@output = [CSSList.new]
		end

		def on_condition(&blk)
			cond = Condition.new(blk,@context)
			@conditions << cond
			cond
		end

		def condition_fingerprint
			fp = ''
			@conditions.each {|c| fp << c.fingerprint(@context).join(C_slash) << '|'}
			fp[0..-2]
		end

		def parse(css = '', context = nil)
			@mutex.lock
			@css = css
			@context = context
			@conditions = []
			clear_output
			eval(css)
			if @cache
				@cache[condition_fingerprint] = to_s
			end
			@context = nil
			@mutex.unlock
		end

		def render(context = nil)
			@mutex.lock
			r = nil
			@context = context
			if @cache and fp = condition_fingerprint and @cache.include?(fp)
				r = @cache[fp]
			else
				@conditions = []
				clear_output
				eval(@css)
				r = to_s
				if @cache
					@cache[condition_fingerprint] = r
				end
				@context = nil
			end	
			@mutex.unlock
			r
		end

		def to_s
			@output.first.to_s
		end

		def self.correct_for_css(t)
			text = t.to_s
			text = text.gsub('_','-') unless text =~ /['"`]/
			#if text.index(' ')
			#	text = "\"#{text}\""
			#end
			text
		end
		
		def method_missing(tag,*args)
			if block_given?
				parent = @output.last
				tagkey = "#{tag}//#{args.join('/')}"
				if parent.has_key?(tagkey)
					selector = parent[tagkey]
				else
					selector = FatAttributeList.has_key?(tag) ? FatAttribute.new(tag) : Selector.new(tag,*args)
					parent[tagkey] = selector
				end
				@output.push selector
				yield
				@output.pop
				selector
			else
				@output.last[tag] = Attribute.new(tag,args.collect {|x| CSS::correct_for_css(x)}.join(','))
			end
		end

		def universal
			parent = @output.last
			selector = Selector.new(:*)
			parent[:*] = selector
			@output.push selector
			yield
			@output.pop
		end

		def Group(*args)
			selectors = []
			if block_given?
				args.reverse.each do |sel|
					parent = @output.last
					parent.push sel
					@output.push sel
					yield
					@output.pop
					selectors << sel
				end
			end
			selectors
		end

		def Literal(arg)
			lit = Literal_.new(arg)
			@output.last[lit.object_id] = lit
		end
			
		class Media < CSSList
			def self.method_missing(media_type,&blk)
				t = []
				eval("lambda {|x| x.replace [@output]}",blk).call(t)
				output = t.first
				parent = output.last
				media = self.new(media_type)
				parent.push media
				output.push media
				yield
				output.pop
			end

			def initialize(media_type)
				@media_type = media_type
				super()
			end

			def to_s
				r = "@media #{@media_type} {\n"
				each do |key,value|
					r << value.to_s('  ')
				end
				r << "}\n"
			end
		end

	end
end
