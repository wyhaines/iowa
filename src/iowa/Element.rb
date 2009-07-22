module Iowa

	# Superclass for all Iowa elements.  An element is something that looks
	# like an HTML tag, and is in many cases named like an HTML tag, but
	# that implements some sort of dynamic behavior.

	class Element

		ElementClasses={Celement => Element}
		def Element.inherited(subclass)
			if subclass.name[0,33] == 'Iowa::Application::ContentClasses'
				ElementClasses[subclass.name.sub(/Iowa::Application::ContentClasses::/,C_empty).downcase] = subclass
			else
				ElementClasses[subclass.name.split(ClassSeparator).last.downcase] = subclass
			end
		end
	
		def Element.newElement(classname, name, bindings, attributes, namespace = nil)
			if name == CBodyContent
				BodyContent.new(name, bindings, attributes)
			else
				klass = nil
				if namespace
					# Is there a more efficient way to do this?
					cn = (namespace.gsub(/Iowa::Application::ContentClasses(::)*/,C_empty).split(ClassSeparator)[0..-2] << classname).join(ClassSeparator)
					klass = ElementClasses[cn.downcase] if ElementClasses.has_key? cn.downcase
				end
				klass ||= ElementClasses[classname.downcase]
				
				begin
					unless klass.ancestors.include?(Iowa::Component)
						klass.new(name, bindings, attributes)	
					else
						ComponentProxy.new(klass, name, bindings, attributes)
					end
				rescue Exception => ex
				raise "unknown Element type: #{classname}\n<br />#{ex}<br/>\n#{ex.backtrace}"
					
				end
			end
		end
	
		attr_accessor :name, :children, :raw_template, :raw_bindings, :attributes
	
		def initialize(name, bindings, attributes, raw_template = nil, raw_bindings = nil)
			@name = name
			@raw_template = raw_template
			@raw_bindings = raw_bindings
			@attributes = attributes
			@bindings = {}
			@cached_associations = {}
			defaultBindings()

			bindings.each do |key,val|
				@bindings[key]=val
			end

			@children = []
		end
	
		def self; self; end

		def cached_associations
			@cached_associations
		end

		def addChild(child)
			@children.push child
		end
	
		def each(&b)
			@children.each(&b)
		end
	
		def defaultBindings
		end
	
		def handleChildren(method, context)
			context.pushElement
			for child in @children
				context.nextElement!
				child.__send__(method, context)
			end
			context.popElement
		end
	
		def handleRequestOrResponse(method, context)
			handleChildren(method, context) if @children.length > 0
		end
	
		def handleRequest(context)
			handleRequestOrResponse(:handleRequest, context)
		end

		def handleResponse(context)
			handleRequestOrResponse(:handleResponse, context)
		end	
	end

end
