module Iowa

	# Parse a template for dynamic elements.
	
	class TemplateParser
	
		Bodyless = {}
		MandatoryBody = {}

		def TemplateParser.register_tag(tag, type = nil)
			# Currently the code only does anything with tags that are
			# :bodyless or :mandatory_body.
			tag_type = tag.name.split(/::/).last.downcase

			case type
			when :bodyless
				Bodyless[tag_type] = true
			when :mandatory_body
				MandatoryBody[tag_type] = true
			end
		end

		#Bodyless = Iowa::Util.hash_from_array(%w(input hr option img))
		#MandatoryBody = Iowa::Util.hash_from_array(%w(repeat table ul ol tr if unless a form select))
		OID = "oid"
		PatternString = "(<\\s*([^>]+?)\\s+([^>]*?" + OID +
						"\\s*=('|\")\\s*(.*?)\\s*(\\4)[^>]*?(/)?\\s*)>)" +
						"|" + "(@{1,2}([\\w.]+))"
						
	  # Regexp constant that defines the regexp to use to parse the template
	  # for dynamic content tags.
		Pattern = Regexp.new(PatternString)

	  # Constant that defines the position in Pattern of the dynamic tag data.

		DynamicTag = 1
		Tag = 2
		Attributes = 3
		ID = 5
		Close = 7
		WholeShortform = 8
		Shortform = 9
		OpenTag = Shortform + 1
		CloseTag = Shortform + 2

		def TemplateParser.strip_html(text)
			attribute_key = /[\w:_-]+/
			attribute_value = /(?:[A-Za-z0-9]+|(?:'[^']*?'|"[^"]*?"))/
			attribute = /(?:#{attribute_key}(?:\s*=\s*#{attribute_value})?)/
			attributes = /(?:#{attribute}(?:\s+#{attribute})*)/
			tag_key = attribute_key
			tag = %r{<[!/?\[]?(?:#{tag_key}|--)(?:\s+#{attributes})?\s*(?:[!/?\]]+|--)?>}
			text.gsub(tag, C_empty).gsub(/\s+/, C_).strip
		end

		# Take the data to parse and the bindings for the template.
		# Store each in object variables, and then parse the template
		# data for dynamic tags.

		def initialize(data, bindings, namespace = nil, dirname = '.')
			@data = data
			@nodestack = [Element.new(CtemplateRoot, {}, {}, data, bindings)]
			@bindings = bindings
			@namespace = namespace.name
			@re_tag_cache = {}

			@pos = 0
			@length = @data.length
			@len = @data.length
			begin
				loop do
					match = Pattern.match(@data[@pos,@len])
					break unless match

					#@data = match.post_match
					@pos += match.end(0)
					@len = @length - @pos
					textToken(match.pre_match)
					parseTag(match)
				end
			rescue Exception => e
				raise "#{e}: parsed error around #{$&}; #{e.backtrace.inspect}"
			end

			textToken(@data[@pos,@len])
			if Iowa.config[Capplication][Cserialize_templates] && namespace.serializeCompiledTemplate
				begin
					File.open(File.join(dirname,".#{@namespace}.iwt"),'w+') do |fh|
						Logger[Ciowa_log].info "Saving compiled template for #{@namespace}"
						fh.print Marshal.dump(root)
					end
				rescue Exception
				end
			else
				Logger[Ciowa_log].info "NOT Saving compiled template for #{@namespace}: #{Iowa.config[Capplication][Cserialize_templates]} & #{namespace.serializeCompiledTemplate}"
			end
		end
		
		# Return the last element of the nodestack.
	
		def root
			@nodestack.last
		end
		
		# Determine if a given tag is part of the set of bodyless tags.
	
		def bodyless?(tag)
			Bodyless.has_key? tag.downcase
		end
		
		def mandatory_body?(tag)
			MandatoryBody.has_key? tag.downcase
		end

		# Parse the contents of a single tag.
	
		def parseTag(match)
			if(match[Shortform])
				if match[WholeShortform][0,2] == C_atat
					startToken('url', match[Shortform], C_)
				else
					startToken(CdynamicString, match[Shortform], C_)
				end
				endToken
				return
			end
	
			startToken(match[Tag], match[ID], match[Attributes])
			
			if (match[Close] and !mandatory_body?(match[Tag])) || bodyless?(match[Tag])
				endToken
				return
			end

			if (match[Close] and mandatory_body?(match[Tag]))
				Logger[Ciowa_log].warn("<#{match[Tag]}> marked as bodyless at character #{@pos}.  Overriding; <#{match[Tag]}> not allowed to be bodyless.")
			end
		
			parseTagBody match[Tag]
		end
		
		# Traverse a tag's body, looking for other dynamic elements embedded
	  # within it.
	
		def parseTagBody(tag)
		
			tagRE = reForTag(tag)
			
			openTags = 1
			
			while(openTags > 0)
			
				tagMatch = tagRE.match(@data[@pos,@len])
				begin
					#@data = tagMatch.post_match
					@pos += tagMatch.end(0)
					@len = @length - @pos
				rescue Exception => exception
					raise exception, "Error while trying to match tag: #{tag}"
				end
				
				if(tagMatch[DynamicTag] || tagMatch[Shortform])
					textToken(tagMatch.pre_match)
					parseTag(tagMatch)
	
				elsif(tagMatch[OpenTag])
					openTags += 1
					textToken(tagMatch.pre_match + tagMatch[0])
	
				elsif(tagMatch[CloseTag])
					openTags -= 1
					textToken(tagMatch.pre_match)	
					textToken(tagMatch[0]) unless openTags == 0
				end
			end
		
			endToken()
		
		end
	
		# Returns a regular expression object that matches either a dynamic
		# element as defined in the global template parsing Pattern, or an
		# opening element of the given tag (argument passed to the method)
		# or a closing element of the given tag.
	
		def reForTag(tag)
			unless @re_tag_cache.has_key?(tag)
				@re_tag_cache[tag] = Regexp.new( PatternString +
					"|" +
					"(<\\s*" + tag + ".*?>)" +
					"|" +
					"(<\\s*/" + tag + "\\s*>)"
				)
			end
			@re_tag_cache[tag]
		end
		
		def startToken(tag, id, attributeString)
			id = "_anon_#{@pos}_#{Time.now.to_f.to_s.gsub('.','')}" if id == C_ or id == C_anon_
			bindings = @bindings[id]
			bindings = {} unless bindings
			
			bindings[Ctag] = LiteralAssociation.new(tag)
			
			attributes = {}
			attributeString.scan(/([\w\-]+)\s*=\s*(["'])(.*?)(\2)/) do |key, quote, value|
				# Attributes with a key that match a binding keyword are treated as a binding.
				key.downcase!
				if value.index('@') == 0
					bindings[key] = Iowa::PathAssociation.new(value[1..-1])
				elsif key != Cvalue and Iowa::BindingKeywords.has_key? key
					bindings[key] = Iowa::BindingKeywords[key].first.new(value)
				else
					attributes[key] = Iowa::Util.unescapeHTML(value) unless key == OID
				end
			end
			klass = bindings[Cklass] ? bindings[Cklass].get : tag
			# Kludge.  I want a regexp that can match both key=value attributes and
			# key only attributes.
			attributes[Cchecked] = nil if attributeString =~ /\bvalue\s*=\s*(["'])checked(\2)/i
			node = Element.newElement(klass, id, bindings, attributes, @namespace)
			@nodestack.last.addChild node
			@nodestack.push node
		end
		
		def endToken
			@nodestack.pop
		end
		
		def textToken(text)
			@nodestack.last.addChild TextElement.new(text)
		end
	
	end

end
