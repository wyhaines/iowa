module Iowa
	class DetachedComponent < Iowa::Component
		def self.template
			@mtemplate
		end

		def self.template=(args)
			if args.is_a?(Array)
				template_data = args[0]
				binding_data = args[1]
			else
				template_data = args
				binding_data = Iowa::C_empty
			end
			@mtemplate = Iowa::TemplateParser.new(template_data,Iowa::BindingsParser.new(binding_data,self.class).bindings,self).root
		end
	end
end
