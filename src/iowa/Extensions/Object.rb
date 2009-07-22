class Object
	# Takes zero or more exceptions as arguments, and supresses the expression of
	# those exceptions in the block that is called.
	def suppress(*exceptions)
		r = nil
		begin
			yield
		rescue *exceptions => r
		end
	end
end
