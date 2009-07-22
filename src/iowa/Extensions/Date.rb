require 'date'
class Date
	def include?(tm)
		dtm = DateTime.parse(tm.asctime)
		slf = self.to_s
		d1 = DateTime.parse("#{slf} 00:00:00")
		d2 = DateTime.parse("#{slf} 23:59:59.99999")
		dtm.between?(d1,d2)
	end

	def to_datetime
		DateTime.new(year, month, day, 0, 0, 0)
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

	def month_start
		Date.new(year, month, 1)
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
		Date.new(year, month, d)
	end

	def year_start
		Date.new(year, 1, 1)
	end

	def year_end
		Date.new(year, 12, 31)
	end
	
end

