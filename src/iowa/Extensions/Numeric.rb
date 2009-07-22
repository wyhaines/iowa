class Numeric

	def seconds
		self
	end
	alias :second :seconds

	def minutes
		self * 60
	end
	alias :minute :minutes

	def hours
		self * 3600
	end
	alias :hour :hours

	def days
		self * 86400
	end
	alias :day :days

	def weeks
		self * 604800
	end
	alias :week :weeks

	def months
		self * 2592000
	end
	alias :month :months

	def years
		self * 31536000
	end
	alias :year :years

	def ago(t = ::Time.now)
		t - self
	end
	alias :until :ago

	def since(t = ::Time.now)
		t + self
	end
	alias :from_now :since
end
