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
			self.each do |k,v|
				next if k.kind_of? String
				self[k.to_s] = v
				self.delete k
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
