module Kernel
	def returning(*vals)
		yield *vals
		vals.length == 1 ? vals.first : vals
	end
end
