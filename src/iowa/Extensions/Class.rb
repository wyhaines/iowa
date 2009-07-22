class Class
	# Return an array containing each of the subclasses of the class.
	# Accepts an optional true/false argument (defaults to false).
	# If false, only returns classes that can currently be instantiated.
	# If true, returns all classes that currently exist.
	def subclasses(all = false)
		found = Hash.new
		ObjectSpace.each_object(Class) do |klass|
			next unless klass.ancestors.include?(self)
			next if (klass == self) or found.has_key?(klass)
			unless all
				if class_exists?(klass)
					found[klass] = true
				end
			else
				found[klass] = true
			end
		end
		found.keys
	end

	# Removes constant definitions for all subclasses of the current class.
	def remove_subclasses
		self.subclasses.each do |klass|
			front = klass.name
			if /::/.match(front)
				front,back = parts(klass.name)
				front_class = front.split('::').inject(Object) { |o,n| o.const_get n }
				front_class.__send__(:remove_const, back)
			else
				Object.__send__(:remove_const, front)
			end
		end
		nil
	end

	# Removes the current class, and all subclasses if true is passed as
	# an argument.
	def remove(all = false)
		remove_subclasses if all
		Object.__send__(:remove_const, self.name)
		nil
	end

	def Class.remove_subclasses(superclass, all = false)
		superclass.remove_subclasses(all)
	end

	def Class.remove(superclass, all = false)
		superclass.remove(all)
	end

	def Class.class_by_name(name)
			name.split('::').inject(Object) { |o,n| o.const_get n }
	end

	def Class.new_by_name(name, *args)
		clean_name = String.new(name.untaint)
		obj = nil
		begin
			obj = Class.class_by_name(clean_name).new(*args)
		rescue Exception => e
			begin
				require clean_name
				obj = Class.class_by_name(clean_name).new(*args)
			rescue Exception
				raise "Unable to create object for class #{clean_name}: #{e}" unless obj
			end
		end
		obj
	end

	private

        def parts(path)
                pieces = path.split('::')
		back = pieces.pop
		front = pieces.join('::')
		[front,back]
        end

	def class_exists?(klass)
		front = klass.name
		if /::/.match(front)
			front, back = parts(front)
			front_class = front.split('::').inject(Object) { |o,n| o.const_get n }
			front_class.constants.include?(back)
		else
			Object.constants.include?(front)
		end
		rescue Exception
			nil
	end
end
