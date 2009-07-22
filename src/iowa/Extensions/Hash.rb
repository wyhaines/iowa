class Hash
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

	def stringify_keys!
		self.each do |k,v|
			next if k.kind_of? String
			self[k.to_s] = v
			self.delete k
		end
	end
end
