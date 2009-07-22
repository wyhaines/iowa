module Iowa
	class String < ::String
		def unescape
		 	   self.gsub(/\+/, ' ').gsub(/%([0-9a-fA-F]{2})/){ [$1.hex].pack("c") }
		end

		def unescape!
			self.gsub!(/\+/, ' ')
			self.gsub!(/%([0-9a-fA-F]{2})/){ [$1.hex].pack("c") }
		end

		def camelCase
			return self if self == ''
			parts = split(/[_\s]/)
			Iowa::String.new(([parts[0].to_s.downcase] + parts[1..-1].collect {|x| x.capitalize}).join)
		end
		alias :camel_case :camelCase
	
		def camelCase!
			replace(camelCase)
		end
		alias :camel_case! :camelCase!

		def constantCase
			return self if self == '' or (self =~ /^[A-Z]/ and self !~ /[_\s]/)
			tmp = camelCase
			tmp[0] = tmp[0].chr.upcase
			Iowa::String.new(tmp)
		end
		alias :constant_case :constantCase

		def constantCase!
			replace(constantCase)
		end
		alias :constant_case! :constantCase!

		# This still is not ideal.  Can be improved more.
		#
		def snake_case(group = true)
			return self unless self =~ %r/[A-Z\s]/
			reverse.scan(%r/[A-Z]+|[^A-Z]*[A-Z]+?|[^A-Z]+/).reverse.map{|word| word.reverse.downcase}.join('_').gsub(/\s/,'_')
		end
		alias :snakeCase :snake_case

		def snake_case!
			replace(snake_case)
		end
		alias :snakeCase! :snake_case

		def human_case
			snake_case.gsub('_',' ').capitalize
		end
		alias :humanCase :human_case

		def human_case!
			replace(human_case)
		end
		alias :humanCase! :human_case!

	end
end
