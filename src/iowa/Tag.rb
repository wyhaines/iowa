require 'iowa/Constants'
require 'iowa/Util'
module Iowa

# Superclass for all Iowa tags.  Tag provides a self referential
# method to determine the tag's name, and to output opening and closing
# HTML representations of the tag.

class Tag < Element

	# Return the name of the tag.

	def tagName
		if @bindings.has_key?(Ctag)
			@bindings[Ctag].get
		else
			self.class.name.split(ClassSeparator).last.downcase
		end
	end
		
	# Output the HTML to open the tag.

	def openTag(*args)
		context = nil
		if args.last.is_a?(Iowa::Context)
			context = args.pop
		end
		#extraAttributes = Hash[*args]
		if args.first.is_a? Hash
			extraAttributes = args.first
		else
			extraAttributes = Hash[*args]
		end
		
		newAttributes = @attributes.dup.update(extraAttributes)

		if context
			@bindings.each do |k,v|
				next if Iowa::BindingKeywords.has_key?(k) and Iowa::BindingKeywords[k][1]
				context.bound_tag = self
				gb = context.getBinding(v)
				newAttributes[k] = gb if gb
				context.bound_tag = nil
			end
		end
		
		tag = "<#{tagName.downcase}"
		newAttributes.each do |key, value| 
			key = Cclass if key == Ctagclass
			if value
				value = Iowa::Util.escapeHTML(value.to_s)
				tag << " #{key}=\"#{value}\""
			else
				tag << " #{key}=\"\""
			end
		end
		tag << C_gt
	end

	def lonelyTag(*args)
		context = nil
		context = args.pop if args.last.is_a?(Iowa::Context)
		if args.first.is_a? Hash
			extraAttributes = args.first
		else
			extraAttributes = Hash[*args]
		end
		
		newAttributes = @attributes.dup.update(extraAttributes)

		if context
			@bindings.each do |k,v|
				next if Iowa::BindingKeywords.has_key?(k) and Iowa::BindingKeywords[k][1]
				context.bound_tag = self
				gb = context.getBinding(v)
				newAttributes[k] = gb if gb
				context.bound_tag = nil
			end
		end
		
		tag = "<#{tagName.downcase}"
		newAttributes.each do |key, value| 
			key = Cclass if key == Ctagclass
			if value
				value = Iowa::Util.escapeHTML(value.to_s)
				tag << " #{key}=\"#{value}\""
			else
				tag << " #{key}=\"\""
			end
		end
		tag << Clonely_tag_terminator
	end
	
	# Output the HTML to close the tag.

	def closeTag
		"</#{tagName.downcase}>"
	end
end

end
