module Iowa
	# Monkey see, Monkey do.
	#
	# That is, use this class to deal with @ usage in templates that doesn't match any existing method.
	#
	class Monkey
		def initialize(val = '')
			@val = val
		end

		def method_missing(meth)
			Monkey.new("#{@val}.#{meth}")
		end

		def to_s
			@val
		end
	end
end

