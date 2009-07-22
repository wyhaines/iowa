module Iowa

class ComponentProxy < Element

	def initialize(klass, *args)
		super(*args)
		@klass = klass
	end
	
	def component(parent)
		component = parent.subcomponents[@name]
		unless component
			component = @klass.new(@name, @bindings, @attributes, parent)
			parent.subcomponents[@name] = component
		end
		component.children = @children
		component
	end
	
	def handleRequestOrResponse(method, context)
		component(context.root).__send__(method, context)
	end

end

end
