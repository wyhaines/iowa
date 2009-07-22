require 'date'
class Time
	def to_date
		Date.new(year, month, day)
		rescue NameError
		nil
	end

	def to_datetime
		DateTime.new(year, month, day, hour, min, sec)
		rescue NameError
		nil
	end

	def ago(sec)
		sec.ago(self)
	end
	alias :until :ago

	def since(sec)
		sec.since(self)
	end
	alias :from_now :since

	def yesterday
		self - 1.day
	end

	def tomorrow
		self + 1.day
	end

	def last_week
		self - 1.week
	end

	def next_week
		self + 1.week
	end

	def last_month
		self - 1.month
	end

	def next_month
		self + 1.month
	end

	def last_year
		self - 1.year
	end

	def next_year
		self + 1.year
	end

	def midnight
		Time.local(year, month, day, 0, 0, 0)
	end

	def month_start
		Time.local(year, month, 1, 0, 0, 0)
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
		Time.local(year, month, d, 0, 0, 0)
	end

	def year_start
		Time.local(year, 1, 1, 0, 0, 0)
	end

	def year_end
		Time.local(year, 12, 31, 0, 0, 0)
	end
	
end
