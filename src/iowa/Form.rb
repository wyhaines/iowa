module Iowa
	module FormElements

		class Form < Tag

			Iowa::TemplateParser.register_tag(self,:mandatory_body)

			def defaultBindings
				@bindings[Caction] = LiteralAssociation.new(@name)
			end
	
			def handleRequest(context)
				if(context.actionID == context.elementID)
					context.setAction(@bindings[Caction])
					context[:formActive] = true
					context.element_attributes = @attributes
				end
				super(context)
				context[:formActive] = false
			end
	
			def handleResponse(context)
				actionURL = context.actionURL
				if @bindings.has_key?(Cid)
					context.url_for_id[context.getBinding(@bindings[Cid])] = actionURL
				end
				context.response << openTag(Cmethod, Cpost,
											 Caction, context.actionURL,
											 	context)
				super(context)
				context.response << closeTag
				context[:skip_pagecache] = false
			end
		end

		class Input < Tag

			#Iowa::TemplateParser.register_tag(self,:bodyless)

			def initialize(name, bindings, attributes)
				type = attributes[Ctype.freeze]
		
				case type
				when Csubmit
					extend Submit
				when Cbutton
					extend Button
				when Cimage
					extend Image
				when Ccheckbox
					extend Checkbox
				when Cradio
					extend Radiobox
				when Cfile
					extend File
				else
					extend Text
				end
		
				super(name, bindings, attributes)
			end
		end

		module Submit

			def defaultBindings
				@bindings[Caction] = LiteralAssociation.new(@name)
				@attributes[Cvalue] ||= @name
			end
	
			def handleRequest(context)
				if context.request.params.has_key?(context.elementID)
					context.setAction(@bindings[Caction])
					context.element_attributes = @attributes
				end
			end
	
			def handleResponse(context)
				value = context.getBinding(@bindings[Cvalue])
				attrs = Hash[Ctype, Csubmit, Cname, context.elementID, Cid, context.elementID]
				attrs[Cvalue] = value if value
				context.response << lonelyTag(attrs,context)
				context[:skip_pagecache] = false
			end
		end

		module Button

			def defaultBindings
				@bindings[Caction] = LiteralAssociation.new(@name)
				@attributes[Cvalue] ||= @name
			end
	
			def handleRequest(context)
				if context.request.params.has_key?(context.elementID)
					context.setAction(@bindings[Caction])
					context.element_attributes = @attributes
				end
			end
	
			def handleResponse(context)
				value = context.getBinding(@bindings[Cvalue])
				attrs = Hash[Ctype, Cbutton, Cname, context.elementID, Cid, context.elementID]
				attrs[Cvalue] = value if value
				context.response << lonelyTag(attrs,context)
				context[:skip_pagecache] = false
			end

		end

		module Image

			def defaultBindings
				@bindings[Caction] = LiteralAssociation.new(@name)
			end
	
			def handleRequest(context)
				if context.request.params.has_key?(context.elementID)
					context.setAction(@bindings[Caction])
					context.element_attributes = @attributes
				end
			end
	
			def handleResponse(context)
				value = context.getBinding(@bindings[Cvalue])
				attrs = Hash[Ctype, Cimage, Cname, context.elementID, Cid, context.elementID]
				context.response << lonelyTag(attrs,context)
				context[:skip_pagecache] = false
			end
		end

		module Text

			def defaultBindings
				@bindings[Cvalue] = PathAssociation.new(@name)
				@bindings[Cmultiple] = nil
			end
	
			def handleRequest(context)
				val = context.request.params[context.elementID]
				if val
					if @bindings[Cmultiple]
						v = context[:responseNotes][@bindings[Cvalue]] || []
						v << val
						context.setBinding(@bindings[Cvalue], v, true)
					else
						context.setBinding(@bindings[Cvalue], val, true)
					end
				end
			end
	
			def handleResponse(context)
				label = @attributes[Clabel]
        html_id = @attributes[Cid]
				if label
					label_class = " class=\"#{@attributes['label_class']}\""
				end
				value = context.getBinding(@bindings[Cvalue])
				type = @attributes[Ctype]
				attrs = Hash[Ctype, type, Cname, context.elementID, Cvalue, value, Cid, html_id || context.elementID]
				#context.response << lonelyTag(Ctype, type,
				#	Cname, context.elementID,
				#	Cvalue, value,context)
				context.response << "<label for=\"#{context.elementID}\"#{label_class}>#{label}</label>" if label
				context.response << lonelyTag(attrs,context)
				context[:skip_pagecache] = false
			end
		end

		module File
			def defaultBindings
				@bindings[Cvalue] = PathAssociation.new(@name)
				@bindings[Cmultiple] = nil
			end
	
			def handleRequest(context)
				val = context.request.params[context.elementID]
				if val
					if @bindings[Cmultiple]
						v = context[:responseNotes][@bindings[Cvalue]] || []
						v << val
						context.setBinding(@bindings[Cvalue], v, true)
					else
						context.setBinding(@bindings[Cvalue], val, true)
					end
				end
			end
	
			def handleResponse(context)
				label = @attributes[Clabel]
				if label
					label_class = " class=\"#{@attributes['label_class']}\""
				end
				value = context.getBinding(@bindings[Cvalue])
				type = @attributes[Ctype]
				attrs = Hash[Ctype, type, Cname, context.elementID, Cid, context.elementID]
				context.response << "<label for=\"#{context.elementID}\"#{label_class}>#{label}</label>" if label
				context.response << lonelyTag(attrs,context)
				context[:skip_pagecache] = false
			end
		end

		module Checkbox
			def defaultBindings
				@bindings[Cvalue] = PathAssociation.new(@name)
			end
	
			def handleRequest(context)
				if context[:formActive]
					val = context.request.params[context.elementID] ? context.request.params[context.elementID] : false
					context.setBinding(@bindings[Cvalue], val, true) if val
				end
			end
	
			def handleResponse(context)
				val = context.getBinding(@bindings[Cvalue]).to_s
				attrs = {Ctype => Ccheckbox,
						 Cname => context.elementID,
						 Cvalue => @attributes[Cvalue],
             Cid => context.elementID}
				attrs[Cchecked] = nil if val && val.to_s != ''
				context.response << lonelyTag(attrs,context)
				context[:skip_pagecache] = false
			end
		end

		module Radiobox
			def defaultBindings
				@bindings[Cvalue] = PathAssociation.new(@name)
			end
	
			def handleRequest(context)
				if context[:formActive]
					val = context.request.params[context.elementID]
					context.setBinding(@bindings[Cvalue], val, true) if val
				end
			end
	
			def handleResponse(context)
				val = context.getBinding(@bindings[Cvalue])
				attrs = {Ctype => Cradio, Cvalue => @attributes[Cvalue]}
				if @attributes[Cname] !~ /^\d+(\.\d+)*$/
					if context.radio_box_id.has_key? @name
						attrs[Cname] = context.radio_box_id[@name]
					else
						context.radio_box_id[@name] = context.elementID
						attrs[Cname] = context.elementID
					end
				else
					attrs[Cname] = @name
				end
				
				if @attributes[Cvalue].to_s == val.to_s
					attrs[Cchecked] = nil
					@attributes.delete(Cchecked)
				elsif val
					@attributes.delete(Cchecked)
				end
				attrs[Cid] = attrs[Cname]

				context.response << lonelyTag(attrs,context)
				context[:skip_pagecache] = false
			end
		end

    class Button < Tag

      Iowa::TemplateParser.register_tag(self, :mandatory_body)

      def initialize(name, bindings, attributes)
        super(name, bindings, attributes)
      end

			def defaultBindings
				@bindings[Caction] = LiteralAssociation.new(@name)
				@attributes[Cvalue] ||= @name
			end
	
			def handleRequest(context)
				if context.request.params.has_key?(context.elementID)
					context.setAction(@bindings[Caction])
					context.element_attributes = @attributes
				end
			end
	
			def handleResponse(context)
			  #value = context.getBinding(@bindings[Cvalue]) if context.testBinding(@bindings[Cvalue])
			  value = context.getBinding(@bindings[Cvalue])
				attrs = Hash[Cname, context.elementID, Cid, context.elementID]
				#attrs[Cvalue] = value if value
				#context.response << openTag(Cname, context.elementID,context)
			  context.response << openTag(attrs, context)
			  context.response << value if value
super(context)
			  #handleChildren(:handleResponse, context)
			  context.response << closeTag
				#context[:skip_pagecache] = false
			end

    end

		class Textarea < Tag
			def defaultBindings
				@bindings[Cvalue] = PathAssociation.new(@name)
			end
	
			def handleRequest(context)
				val = context.request.params[context.elementID]
				if val
					context.setBinding(@bindings[Cvalue], val, true)
				end
			end
	
			def handleResponse(context)
				value = context.getBinding(@bindings[Cvalue])
				context.response << openTag(Cname, context.elementID,Cid, context.elementID, context)
				context.response << value.to_s
				context.response << closeTag
				context[:skip_pagecache] = false
			end
		end

		class Select < RepeatReadOnly
	
			Iowa::TemplateParser.register_tag(self,:mandatory_body)

			# If the multiple option is used in the select statement, then multiple
			# values can be returned.  If they are, then the 'item' variable will
			# be set to an array, with each selection as an element in the array.

			def handleRequest(context)
				index = context.request.params[context.elementID]
				handleRequestOrResponse(:handleRequest, context)
				if index
					list = context.getBinding(@bindings[Clist])
					if index.index(0)
						c = []
						#index.split(0.chr).each do |i|
						for i in index.split(0.chr)
							c.push list[i.to_i]
						end
						context.setBinding(@bindings[Citem], c, true)
					else
						context.setBinding(@bindings[Citem], list[index.to_i], true)
					end
				end
			end
	
			def handleResponse(context)
				context.response << openTag(Cname, context.elementID,Cid, context.elementID, context)
				handleRequestOrResponse(:handleResponse, context)
				context.response << closeTag
				context[:skip_pagecache] = false
			end
	
			# If the item is an array, then there are multiple entries within the
			# select box that are selected.

			def handleRequestOrResponse(method, context)
				setupBindings(context)
				list = context.getBinding(@bindings[Clist])
				item = context.getBinding(@bindings[Citem])
				if item.kind_of?(Array)
					h = {}
					#item.each do |i|
					for i in item
						h[list.index(i)] = true
					end
					context[:selectItem] = h
				else
					context[:selectItem] = list.index(item)
				end
				context[:selectIndex] = 0
		
				super(method, context)
		
				context.setBindingNow(@bindings[Citem], item, true)
			end
		end

		class Option < Tag

			Iowa::TemplateParser.register_tag(self,:bodyless)

			def defaultBindings
				@bindings[Citem] = PathAssociation.new(@name)
			end
	
			def handleResponse(context)
				attrs = {Cvalue, context[:selectIndex], Cid, context.elementID }
		
				if context[:selectItem].class.name == CHash
					if context[:selectItem].has_key? context[:selectIndex]
						attrs[Cselected] = nil
					end
				elsif context[:selectIndex] == context[:selectItem]
					attrs[Cselected] = nil
				end

				context.response << openTag(attrs,context)
				context.response << context.getBinding(@bindings[Citem]).to_s

				context[:selectIndex] += 1
				context[:skip_pagecache] = false
			end
		end
	end
end
