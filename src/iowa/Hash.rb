module Iowa

	# This is a subclass of Ruby's Hash that implements a few convenient
	# methods used by IOWA.
	
	class Hash < Hash

		# A simple little routine to downcase any String used as a key
		# in a hash or any hash nested as value somewhere within the hash.
		# Thanks to Daniel Berger for this implementation.

		def downcase_keys!
			upper = /A-Z/
			self.each do |k,v|
				next unless k.kind_of? String
				self[k.dup.downcase] = v
				self.delete(k) if upper.match(k)
			end
		end

		# Convert any symbolic keys to strings.
		
		def stringify_keys!
			current_keys = self.keys
			current_keys.each do |k|
				v = self[k]
				self.delete k
				self[k.to_s] = v
			end
		end
		
		# Convert any string keys to symbols.
		
		def symbolify_keys!
			current_keys = self.keys
			current_keys.each do |k|
				v = self[k]
				self.delete k
				self[k.to_s.intern] = v
			end
		end

		def symbolify_all_keys!
			current_keys = self.keys
			current_keys.each do |k|
				v = self[k]
				v.symbolify_all_keys! if v.respond_to?(:has_key?)
				self.delete k
				self[k.to_s.intern] = v
			end
		end
		
		def step_merge!(h)
			h.each do |k,v|
				if v.kind_of?(::Hash)
					if self[k].kind_of?(::Hash)
						unless self[k].respond_to?(:step_merge!)
							if dp = self[k].default_proc
								self[k] = Iowa::Hash.new {|h,k| dp.call(h,k)}.step_merge!(self[k])
							else
								osk = self[k]
								self[k] = Iowa::Hash.new
								self[k].step_merge!(osk)
							end
						end
						self[k].step_merge!(v)
					else
						if self.default_proc
							self.delete k
							self[k]
						end
						unless self[k].kind_of?(::Hash)
							self.delete k
							self[k] = Iowa::Hash.new
						end
						self[k].step_merge!(v)
					end
				else
					self[k] = v
				end
			end
		end

	end
end
