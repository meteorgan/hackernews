#!/usr/bin/env ruby

require "date"

def request(url)
	result = ''
	open(url) {|f|
		result = f.read
	}
end

def time_to_date(str)
	# bug: the timezone using here is +8, may not same with hacker news
	times, unit = str.split()
	date = ''
	today = Date.today
	if unit == "days"
		date = (today - times.to_i).to_s
	else
		date = today.to_s
	end

	return date
end
