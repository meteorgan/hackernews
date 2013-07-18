#!/usr/bin/env ruby

require "date"

def request(url)
    result = ''
    retry_number = 3
    begin
        open(url) {|f|
            result = f.read
        }
    rescue HTTPerror => e
        if retry_number > 0
            sleep 5
            retry_number -= 1
            retry
        else
            puts e
        end
    end
end

def time_to_date(str)
    # bug: the timezone using here is +8, may not same as hacker news
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
