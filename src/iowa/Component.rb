require 'iowa/JSON-lexer'
require 'iowa/caches/SimpleLRUCache'
require 'iowa/Monkey'
module Iowa

	# Provides high level functionality for all component subclasses.
	# Each "page" in an Iowa app is a Component subclass.

	class Component < Element
		include Iowa::Caches::SimpleLRUCache::Item

		@max_cache_entries = nil
		def self.max_cache_entries; @max_cache_entries; end
		def self.MaxCacheEntries(val=nil)
			if val
				@max_cache_entries = val
			else
				@max_cache_entries
			end
		end

		@@serializeCompiledTemplate = true

		def Component.serializeCompiledTemplate
			@@serializeCompiledTemplate
		end

		def Component.serializeCompiledTemplate=(val)
			@@serializeCompiledTemplate = val
		end

		def Component.bindings
			{}
		end

	  # Returns the template for the component.

		def Component.template
			Iowa.app.templateForComponent(self.name)
		end

	  # Finds and returns the named component.  Other methods calling this
	  # one with different values for session and prevPage could induce some
	  # interesting (or bizarre) behaviors.  See pageNamed(name) below for
	  # the standard invocation.

		def Component.pageNamed(name, session, prevPage=nil,import_attempted=nil,raise_exception=true)
			Iowa.app.reloadModified(name,true)
			klass = ElementClasses[name.to_s.downcase]
			if(klass && klass.ancestors.include?(Component))
				page = klass.new(Cpage, {}, {}, prevPage)
				page.prevPage = prevPage
				page.session = session
				page
			else
				if !import_attempted
					import_attempted = true
					Iowa::Log.info("#{name} -- #{self.name}")
					Iowa.app.import(name,self.name)
					pageNamed(name.capitalize,session,prevPage,true,raise_exception)
				elsif raise_exception
					session.context.response.status = 404
					raise "#{name}: No component found."
				else
					nil
				end
			end
		end

	  # Provides a method to define component attributes which another
	  # component can bind to.
	
		def Component.attr_binding(*symbols)
			symbols.each do |symbol|
				class_eval %{
					def #{symbol}
						if @bindings.has_key?('#{symbol}')
							@bindings['#{symbol}'].get(@parent)
						else
							nil
						end
					end
					def #{symbol}=(val)
						if @bindings.has_key?('#{symbol}')
							@bindings['#{symbol}'].set(@parent, val)
						else
							@bindings['#{symbol}'] = LiteralAssociation.new(val)
						end
					end
				}
			end
		end
	
		# If fingerprint is overridden to return a non-nil value, that value will
		# be used as a cache key for the rendered content.  If a future request
		# returns the same fingerprint, the cached content will be returned.
		# IOWA will not permit any session-specific renderings to be cached.
		def fingerprint
			nil
		end

	  # Standard invocation of Component.pageNamed.  Returns the component
	  # corresponding the the given name.
	
		def page_named(name, *args)
			my_name = self.class.name.gsub(/Iowa::Application::ContentClasses::/,C_empty).split(ClassSeparator)
			my_name.pop
			my_name << name
			#relative_name = "#{my_name.join('::')}::#{name}"
			relative_name = my_name.join(ClassSeparator)

			iter = 0
			component = nil
			loop do
				if ElementClasses.has_key?(relative_name.downcase)
					break component = Component.pageNamed(relative_name, @session, self)
				else
					if iter < 1
						iter += 1
						Iowa.app.reloadModified(relative_name,true)
						retry
					else
						break component = Component.pageNamed(name, @session, self)
					end
				end
			end
			args.each do |arg|
				if arg.respond_to?(:each)
					arg.each {|k,v| component.__send__(k,v)}
				else
					component.__send__(arg)
				end
			end

			component
		end
		alias :pageNamed :page_named
		alias :componentNamed :page_named
		alias :component_named :page_named

		# Define a method called "meth" to show the page named "page".
		def self.proceed(meth, page)
			module_eval(<<-EVAL)
				def #{meth}
					yield page_named('#{page}')
				end
			EVAL
		end

		# Define a method called "meth" to show the page named "page"
		# after executing the "block" in the destination page's context.
		def self.proceed_with(meth, page, &block)
			define_method("__#{meth}__primer__".intern, block)
			module_eval(<<-EVAL)
				def #{meth}
					p = page_named('#{page}')
					__#{meth}__primer__(p)
					yield p
				end
			EVAL
		end


		# Default to individual components allowing themselves to be docroot cached.
		# To change this, in the component, one can use the class method:
		# 
		#   disallow_docroot_caching
		#
		# or the object method:
		#
		#   self.allow_docroot_caching = false

		attr_accessor :session, :prevPage, :subcomponents, :parent, :creation_time

	  # Handle the initial tasks that establish the state of the new object.

		def initialize(name, bindings, attributes, parent)
			self.cacheable = true unless @cacheable == false
			self.replaceable = false unless replaceable?
			self.fragment = false unless fragment?
			@creation_time = Time.now
			@parent = parent
			@session = parent ? parent.session : nil

			self.allow_docroot_caching = false if allow_docroot_caching?.nil?

			@subcomponents = {}
			super(name, bindings, attributes)

			awake()
		end

		def context
			@session.context
		end

		def url_for_id
			@session.context.url_for_id
		end

		def cacheable
			@cacheable
		end

		def cacheable?
			@session.context[:request_cacheable] || cacheable
		end

		def cacheable=(val)
			@cacheable = val ? true : false
		end

		def replaceable
			@replaceable
		end

		def replaceable?
			replaceable
		end

		def replaceable=(val)
			@replaceable = val ? true : false
		end

		def fragment
			@fragment
		end

		def fragment=(val)
			@fragment = val ? true : false
		end

		def fragment?
			fragment
		end

		def self.allow_docroot_caching
			@allow_docroot_caching = true
		end

		def self.disallow_docroot_caching
			@allow_docroot_caching = false
		end
		
		def self.allow_docroot_caching?
			@allow_docroot_caching
		end

		def allow_docroot_caching?
			self.class.allow_docroot_caching?
		end

		def allow_docroot_caching=(val)
			klass = self.class
			val ? klass.allow_docroot_caching : klass.disallow_docroot_caching
		end

	  # Stub, intended to be overridden in the subclasses, to define behavior
	  # that occurs only once, when the object is first created.

		def awake
		end

	  # Stub, intended to be overridden in the subclasses, to define behavior
	  # that occurs when backtracking.

		def handle_backtrack
		end
		alias :handleBacktrack :handle_backtrack

		# Stub, intended to be overridden in the subclasses, to define behavior
		# that occurs each time the component is displayed.
		
		def setup
		end

		# Takes the result of some method, plus the id of the originating
		# JSON-RP call, and creates the JSON-RPC reponse
		def format_repsonse( result, error, id )
		quote = '"'
			'{ "result" : ' + result.to_json + 
				', "error":"' + error.to_s + 
				'", "id": ' +  quote +  id.to_s + quote + ' }'
		end
		
		def json_methods
			[:list_methods]
		end

		def list_methods
			json_methods
		end

		# Sets up a standard method that will return a URL for handling JSON-RPC
		# requests.
		def json
			session.resource_url do
				# Get the request info
				content = @session.context.response.body
				
				# Create new JSON lexer
				jsonobj = {}.from_json(JSON::Lexer.new(content))
				# Decode request
				r = nil
				error = nil
				# Verify that it is for an allowed method
				# Call Method
				params = jsonobj[Cparams] ? jsonobj[Cparams] : []
				
				begin
					if json_methods.include?(jsonobj[Cmethod].to_sym)
						r = params.size < 1 ?
							self.__send__(jsonobj[Cmethod]) :
							self.__send__(jsonobj[Cmethod], *jsonobj[Cparams])
					end
				rescue Exception => e
					error = e.to_s
				end
				# Return Resource
				Iowa::Resource.new(format_repsonse( r, error, jsonobj[Cid] || Cdefault ),Ctext_javascript)
			end
		end

	  # Returns the Application object.

		def application
			Iowa.app
		end
	
	  # Trigger an action on the component.
	
		def invokeAction(action, args, &b)
			arty = method(action).arity
			if args.length == arty or arty == -1
				__send__(action, *args, &b)
			end
		end
	
		def handleResponse(context,return_response = false)
			@template = self.class.template
			setup
			if return_response
				old_response = context.response
			end
			handleRequestOrResponse(:handleResponse, context)
			if return_response
				context.response = old_response
			end
		end
	
		def handleRequest(context)
			handleRequestOrResponse(:handleRequest, context)
			end
	
		def handleRequestOrResponse(method, context)
			Iowa.app.reloadModified(self.class.name,true)
			
			context.pushRoot self
			@template.__send__(method, context)
			context.popRoot
		end
	
		def getBinding(binding)
			@bindings[binding].get(@parent)
		end
	
		def setBinding(binding, value)
			@bindings[binding].set(@parent, value)
		end
	
		def dup
			copy = super
			copy.subcomponents = {}
			copy.creation_time = Time.now
			@subcomponents.each do |name, child|
				newChild = child.dup
				newChild.parent = copy
				copy.subcomponents[name] = newChild
			end
			copy
		end
	
		def back; yield @prevPage if @prevPage; end
	
		def reload; end
	
		# This is a default method_missing handler that will keep Ruby from going
		# down the path of a very, very long backtrace generation in the event
		# of this kind of error (which is an easy error to make).
		
		def method_missing(*args)
			raise "Method missing: #{args.inspect}"
		end

		def method_missing(*args)
			Monkey.new("@#{args[0]}")
		end
			
	end

end
