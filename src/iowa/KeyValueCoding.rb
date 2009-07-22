require 'iowa/Constants'

class Object
	
	def takeValueForKey(value, key)
		__send__("#{key}=", value)
	end
	
	def valueForKey(key)
		__send__(key)
	end
	
	def takeValueForKeyPath(value, keyPath)
		keys = keyPath.split(Iowa::C_dot)
		lastKey = keys.pop
		target = self
		for key in keys
			target = target.valueForKey(key)
		end
		target.takeValueForKey(value, lastKey)
	end
	
	def valueForKeyPath(keyPath)
		keys = keyPath.split(Iowa::C_dot)
		result = self
		keys.each_index do |i|
			if keys[i] =~ /^[&](.*)/
				return result.__send__($1) do |val|
					val.valueForKeyPath(keys[i+1..-1].join(Iowa::C_dot))
				end
			end	
			result = result.valueForKey keys[i]
		end
		result
	end

	def valueForKeyPathWithArgs(keyPath,*args)
		keys = keyPath.split(Iowa::C_dot)
		final_method = keys.pop
		result = self
		keys.each_index do |i|
			if keys[i] =~ /^[&](.*)/
				return result.__send__($1) do |val|
					val.valueForKeyPath(keys[i+1..-1].join(Iowa::C_dot))
				end
			end	
			result = result.valueForKey keys[i]
		end
		args.length == 0 ? result.__send__(final_method) : result.__send__(final_method,*args)
	end

	def existsKeyPath?(keyPath)
		keys = keyPath.split(Iowa::C_dot)
		lastKey = keys.pop
		target = self
		keys.each_index do |i|
			if keys[i] =~ /^[&](.*)/
				return target.__send__($1) do |val|
					val.existsKeyPath?(keys[i+1..-1].join(Iowa::C_dot))
				end
			end
			target = target.valueForKey keys[i]
		end
		target.respond_to?(lastKey)
		rescue Exception => e
			false
	end
end

class Hash

	def takeValueForKey(value, key)
		self[key] = value
	end
	
	def valueForKey(key)
		self[key]
	end
end

class Array

	def takeValueForKey(value, key)
		self[key.to_i] = value
	end
	
	def valueForKey(key)
		self[key.to_i]
	end
end

