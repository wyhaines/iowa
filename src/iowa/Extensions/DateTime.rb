require 'date'
class DateTime
	def to_time
puts year, month, day, hour, min, sec
		Time.local(year,month,day,hour,min,sec)
	end

	def to_date
		Date.new(year, month, day)
		rescue NameError
		nil
	end

	def ago(sec)
		self - Rational.new!(sec, 86400)
	end
	alias :until :ago

	def since(sec)
		self + Rational.new!(sec, 86400)
	end
	alias :from_now :since

	def yesterday
		self - 1
	end

	def tomorrow
		self + 1
	end

	def last_week
		self - 7
	end

	def next_week
		self + 7
	end

	def last_month
		self - 30
	end

	def next_month
		self + 30
	end

	def last_year
		self - 365
	end

	def next_year
		self + 365
	end

	def midnight
		DateTime.new(year, month, day, 0, 0, 0)
	end

	def month_start
		DateTime.new(year, month, 1, 0, 0, 0)
	end

	def month_end
		d = {1 => 31,
			2 => Date.new(year, month, day).leap? ? 29 : 28,
			3 => 31,
			4 => 30,
			5 => 31,
			6 => 30,
			7 => 31,
			8 => 31,
			9 => 30,
			10 => 31,
			11 => 30,
			12 => 31}[month]
		DateTime.new(year, month, d, 0, 0, 0)
	end

	def year_start
		Time.local(year, 1, 1, 0, 0, 0)
	end

	def year_end
		Time.local(year, 12, 31, 0, 0, 0)
	end
	
end
