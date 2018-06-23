require 'iowa/ImageSize'
require 'iowa/Webcache'

# Notes on tags and tag logic:
# Currently all "builtin" tags are defined in two files, DynamicElements.rb
# and Form.rb.  This should be broken up and restructured.  Tags, or at least
# familes of tags (i.e. all input type tags are a family) should each be
# be defined in a separate file, and there should be some sort of "include path"
# for finding tags.  This makes it easy to add new tags without editing any
# core files.

module Iowa

	class P < Tag
		def defaultBindings
			@bindings[Cvalue] = PathAssociation.new(@name)
		end
	
		def handleRequest(context)
			handleChildren(:handleRequest, context)
		end
	
		def handleResponse(context)
			value = context.getBinding(@bindings[Cvalue]) if context.testBinding(@bindings[Cvalue])
			context.response << openTag(context)
			context.response << value if value
			handleChildren(:handleResponse, context)
			context.response << closeTag
		end
	end

	# There is a pile of HTML tag types which are essentially just containers,
	# like a <p>.  In the context of a browser, they each have different meanings,
	# but in IOWA, they are all just containers.
	
	class Abbr < P; end
	class Acronym < P; end
	class Address < P; end
	class B < P; end
	class Bdo < P; end
	class Big < P; end
	class Blockquote < P; end
	class Body < P; end
	class Button < P; end
	class Caption < P; end
	class Cite < P; end
	class Code < P; end
	class Colgroup < P; end
	class Dd < P; end
	class Del < P; end
	class Div < P; end
	class Dfn < P; end
	class Dt < P; end
	class Em < P; end
	class Fieldset < P; end
	class Frameset < P; end
	class H1 < P; end
	class H2 < P; end
	class H3 < P; end
	class H4 < P; end
	class H5 < P; end
	class H6 < P; end
	class Head < P; end
	class Html < P; end
	class I < P; end
	class Iframe < P; end
	class Ins < P; end
	class Kbd < P; end
	class Label < P; end
	class Legend < P; end
	class Li < P; end
	class Map < P; end
	class Noframes < P; end
	class Noscript < P; end
	class Object < P; end
	class Optiongroup < P; end
	class Pre < P; end
	class Q < P; end
	class Samp < P; end
	class Script < P; end
	class Small < P; end
	class Span < P; end
	class Strong < P; end
	class Style < P; end
	class Sub < P; end
	class Sup < P; end
	class TBody < P; end
	class TFoot < P; end
	class THead < P; end
	class Title < P; end
	class TT < P; end
	class Var < P; end

	class LonelyTag < Tag
		def handleResponse(context)
			context.response << lonelyTag(context)
		end
	end

	class Area < LonelyTag; Iowa::TemplateParser.register_tag(self,:bodyless); end
	class Base < LonelyTag; Iowa::TemplateParser.register_tag(self,:bodyless); end
	class Col < LonelyTag; Iowa::TemplateParser.register_tag(self,:bodyless); end
	class Frame < LonelyTag; Iowa::TemplateParser.register_tag(self,:bodyless); end
	class Link < LonelyTag; Iowa::TemplateParser.register_tag(self,:bodyless); end
	class Meta < LonelyTag; Iowa::TemplateParser.register_tag(self,:bodyless); end
	class Param < LonelyTag; Iowa::TemplateParser.register_tag(self,:bodyless); end

# Subclass of Tag that defines an Iowa anchor element.

	class A < Tag

		Iowa::TemplateParser.register_tag(self,:mandatory_body)

		# The default binding for an anchor is to establish an action
		# with a literal association.  i.e. oid="frumption" binds a
		# call to "frumption" as the action for the element.
	
		def defaultBindings
			@bindings[Caction] = LiteralAssociation.new(@name)
		end
		
		def handleRequest(context)
			if(context.actionID == context.elementID)
				context.setAction(@bindings[Caction])
				context.element_attributes = @attributes.dup
				rc = Iowa.response_cacheable_from_attributes?(@attributes)
				context[:request_cacheable] = rc if !rc.nil?
			end
			
			handleChildren(:handleRequest, context)
		end
		
		def handleResponse(context)
			actionURL = context.actionURL
			if @bindings.has_key?(Cid)
				context.url_for_id[context.getBinding(@bindings[Cid])] = actionURL
			end
			context.response << openTag(Chref, actionURL, context)
			handleChildren(:handleResponse, context)
			context.response << closeTag
			context[:skip_pagecache] = false
		end
	end
	
	class Url < A

		Iowa::TemplateParser.register_tag(self,:bodyless)

		def handleResponse(context)
			actionURL = context.actionURL
			if @bindings.has_key?(Cid)
				context.url_for_id[context.getBinding(@bindings[Cid])] = actionURL
			end
			context.response << actionURL
			context[:skip_pagecache] = false
		end
	end

	class Img < Tag

		Iowa::TemplateParser.register_tag(self,:bodyless)
			
		def webcache_size; 100; end
		
		def initialize(*args)
			@@image_size_cache ||= {}
			@@webcache = Iowa::Webcache.new(webcache_size)
			super(*args)
		end
		
		def defaultBindings
			@bindings[Caction] = LiteralAssociation.new(@name)
		end

		def get_image_size_by_path(path)
			File.open(path) {|fh| Iowa::ImageSize.new(fh)}
		end

		def get_image_size_by_data(data)
			Iowa::ImageSize.new(data.to_s)
		end

		# Change this so it can take a local path OR a URL.
		def handleResponse(context)
			image_url,image_path = context.getBinding(@bindings[Caction])
			img = nil
			if image_path.to_s != '' && FileTest.exists?(image_path)
				img = nil
				unless @@image_size_cache.has_key?(Cimage_path)
					img = get_image_size_by_path(image_path)
					@@image_size_cache[image_path] = [img,File.stat(image_path)]
				else
					img,st = @@image_size_cache[image_path]
					if File.stat(image_path).mtime != st.mtime
						img = get_image_size_by_path(image_path)
						@@image_size_cache[image_path] = [img.File.stat(image_path)]
					end
				end
			elsif image_url.to_s != ''
				if data = @@webcache[image_url]
					@@image_size_cache[image_url] = get_image_size_by_data(data)
				end
				img = @@image_size_cache[image_url]
			end
			if img
				if (img.height) and (img.width)
					context.response << openTag(Csrc,image_url,Cheight,img.height,Cwidth,img.width,context)
				else
					context.response << openTag(Csrc,image_url,context)
				end
				handleChildren(:handleResponse, context)
				context.response << closeTag
			else
				context.response << openTag(Csrc,image_url,context)
				handleChildren(:handleResponse, context)
				context.response << closeTag
			end
			context[:skip_pagecache] = false
		end
	end
				
			
	# Subclass of Tag that defines an Iowa string element.
	# Note that Strings are usually referred to in a template
	# via the shortcut syntax of '@foo'.
	
	class DynamicString < Tag
		def defaultBindings
			@bindings[Cvalue] = PathAssociation.new(@name)
		end

		# Short circuits calls back to Element#handleRequest and thus
		# Element#handleChildren since a DynamicString will never have children.

		def handleRequest(context)
		end

		def handleResponse(context)
			val = context.getBinding(@bindings[Cvalue])
			if(val)
				context.response << "#{val}"
			end
		end
	end
	
	# This tag provides a static, mulilingual string capability.  
	# This can be shortcut in a template using ^foo.
	
	class MLString < Tag
		def defaultBindings
			@bindings[Cvalue] = LiteralAssociation.new(@name)
		end

		def handleRequest(context); end

		def handleResponse(context)
			# Need to implement finding the desired string.
			val = context.getBinding(@bindings[Cvalue])
			if (val)
			end
		end
	end

	
	class RepeatReadOnly < Tag
		Iowa::TemplateParser.register_tag(self,:mandatory_body)

		def defaultBindings
			@bindings[Clist] = nil
			@bindings[Citem] = nil
			@bindings[Ckey] = nil
		end

		def commit_callback_setup(list,ras,context); end
		def commit_callback_association(ras,item_idx,context); end

		def setupBindings(context)
			if @bindings[Clist].nil? and @bindings[Citem]
				if @name[0] == 123
					@bindings[Clist] = LiteralAssociation.new(Proc.new {eval(@name[1..-2])})
				else
					@bindings[Clist] = PathAssociation.new(@name)
				end
			elsif @bindings[Citem].nil? and @bindings[Clist]
				@bindings[Citem] = PathAssociation.new(@name)
			elsif @bindings[Clist].nil? and @bindings[Citem].nil?
				if @name[0] == 123
					@bindings[Clist] = LiteralAssociation.new(Proc.new {eval(@name[1..-2])})
					@bindings[Citem] = PathAssociation.new(C_item)
				elsif context.testBinding(PathAssociation.new(@name + C_list))
					@bindings[Clist] = b
					@bindings[Citem] = PathAssociation.new(@name)
				else
					@bindings[Clist] = PathAssociation.new(@name)
					@bindings[Citem] = PathAssociation.new(C_item)
				end
			end

			# Now, check to see if the binding for item responds.  If it does not,
			# create it.

			context.createAccessor(@bindings[Citem]) unless context.testBinding(@bindings[Citem])
		end

		def handleRequestOrResponse(method, context)
			setupBindings(context)
			keystack = context.session[C__keystack]

			list = context.getBinding(@bindings[Clist],nil,keystack.join(C_slash))
			key = @bindings[Ckey]
			ras = context.root
			if list
				context.pushElement
				
				# This lets changes in the iterator get applied back to the list directly.
				# In this read only class, these are noops, but in the subclass, these
				# can be defined.
				commit_callback_setup(list,ras,context)
				
				list.each_index do |item_idx|
					item = list[item_idx]
					keystack.push(item.hash)
					context.setBindingNow(@bindings[Citem], item)
					if(key)
						context.elementID = context.getBinding(key,nil,keystack.join(C_slash))
					else
						context.nextElement!
					end
					commit_callback_association(ras,item_idx,context)
					handleChildren(method, context)
					keystack.pop
				end
				context.popElement
			end
		end
	end

	class RepeatRO < RepeatReadOnly
		Iowa::TemplateParser.register_tag(self,:mandatory_body)
	end

	# Subclass of Tag that implements an Iowa element for repeating
	# portions of a template.

	class Repeat < RepeatReadOnly

		Iowa::TemplateParser.register_tag(self,:mandatory_body)

		def commit_callback_setup(list,ras,context)
			context.commit_callbacks[@bindings[Citem].association] ||= {}
			blk = Proc.new {|val,idx| list[idx] = val}
			context.commit_callbacks[@bindings[Citem].association][ras] = [blk,nil]
		end

		def commit_callback_association(ras,item_idx,context)
			context.commit_callbacks[@bindings[Citem].association][ras][1] = item_idx
		end

	end
	
	# Subclass of Repeat.  Syntactic sugar.
	
	class Table < Repeat	

		Iowa::TemplateParser.register_tag(self,:mandatory_body)

		def handleResponse(context)
			context.response << openTag(context)
			super(context)
			context.response << closeTag
		end
	end
	
	class TR < Table; Iowa::TemplateParser.register_tag(self,:mandatory_body); end
	class UL < Table; Iowa::TemplateParser.register_tag(self,:mandatory_body); end
	class OL < Table; Iowa::TemplateParser.register_tag(self,:mandatory_body); end
	class DL < Table; Iowa::TemplateParser.register_tag(self,:mandatory_body); end

	class SideEffect < Tag

		def handleResponse(context)
			context.response << openTag(context)
			super(context)
			context.response << closeTag
		end
		
		def handleRequest(context)
			handleChildren(:handleRequest, context)
		end
	end

	
	# Subclass of Tag that allows for optional sections within a template.
	# Evaluation is simple.  If the condition (the item referenced by the
	# oid attribute in the tag) evaulates to true (Ruby's notion of true)
	# then the body of the <IF> tag will be displayed.  Otherwise it will
	# not be displayed.
	
	class If < Tag

		Iowa::TemplateParser.register_tag(self,:mandatory_body)


		def defaultBindings
			@bindings[Ccondition] = PathAssociation.new(@name)
		end
		
		def testCondition(condition)
			condition
		end
	
		def handleRequestOrResponse(method, context)
			condition = context.getBinding(@bindings[Ccondition])
			context.element_attributes = @attributes
			if testCondition(condition)
				handleChildren(method, context)
			end
		end
	end
	
	# Subclass of If that implements inverse functionality.  If the
	# condition evaluates to false, then the body of the <UNLESS> tag
	# will be displayed.
	
	class Unless < If

		Iowa::TemplateParser.register_tag(self,:mandatory_body)

		def testCondition(condition)
			!condition
		end
	end
	
	#Deprecated; will be removed.
	# Can we have an Else, too?

	class IfCondition < If
		def handleResponse(context)
			context.response << openTag(context)
			super(context)
			context.response << closeTag
		end
	end

	class TextElement < String
		def handleRequest(context); end
		def handleResponse(context)
                  if self.length == 1
                    context.response << self.chomp
                  else
                    context.response << self
                  end
                end
	end
	
	class BodyContent < Element

		def handleRequestOrResponse(method, context)
			root = context.popRoot
			root.handleChildren(method, context)
			context.pushRoot root
		end
	end

	def Iowa.response_cacheable_from_attributes?(attr)
		if attr.has_key?(Ccacheable) and rc = attr[Ccacheable].downcase
			if rc == C0 or rc == Cfalse
				false
			elsif rc == C1 or rc == Ctrue
				true
			end
		else
			nil
		end
	end

end
