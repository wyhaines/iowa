class String
	def unescape
	 	   self.gsub(/\+/, ' ').gsub(/%([0-9a-fA-F]{2})/){ [$1.hex].pack("c") }
	end

	def unescape!
		self.gsub!(/\+/, ' ')
		self.gsub!(/%([0-9a-fA-F]{2})/){ [$1.hex].pack("c") }
	end

	def camelCase
		return self if /[a-zA-Z][A-Z]/.match(self)
		parts = split(/[_\s]/)
		([parts[0].downcase] + parts[1..-1].collect {|x| x.capitalize}).join
	end
	alias :camel_case :camelCase
	
	def camelCase!
		replace(camelCase)
	end
	alias :camel_case! :camelCase!

	def constantCase
		tmp = camel_case
		tmp[0] = camel_case[0].chr.upcase
		tmp
		rescue self
	end
	alias :constant_case :constantCase

	def constantCase!
		replace(constantCase)
	end
	alias :constant_case! :constantCase!

	def snake_case(group = true)
		if group
			gsub(/([a-zA-Z])([A-Z])/,'\1_\2').gsub(/\s/,'_').downcase
		else
			gsub(/([a-zA-Z])(?=[A-Z])/,'\1_\2').gsub(/\s/,'_').downcase
		end
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