#!/usr/bin/env ruby

require "open-uri"
require "./utils"

#
# get the infomation of a ID in hacker news
#
class UserInfo
	attr_reader :user_id, :create_date, :karma, :avg, :about

	def initialize(user_id)
		@user_id = user_id
		get_user_info
	end

	def submissions
		# notice: there is "more" in the webpage!
	end

	def comments
	end

	def submissions_ids
		submissions_url = "https://news.ycombinator.com/submitted?id=" + @user_id
		result = request(submissions_url)
		
		regexp = %r{ago  \| <a href="item\?id=(\d+)}
	    @submissions_ids = result.scan(regexp).flatten(1)
	end

	def comments_ids
		comments_url = "https://news.ycombinator.com/threads?id=" + @user_id
		result = request(comments_url)

		@comments_ids = result.scan(%r{user\?id=#{@user_id}.*?item\?id=(\d+)}).flatten(1)
	end

	private
	def get_user_info
		user_url = "https://news.ycombinator.com/user?id=" + @user_id
		regexps = {"created"=> %r{created:</td><td>(.*?) ago},
			       "karma"  => %r{karma:</td><td>(\d+)},
				   "avg"    => %r{avg:</td><td>(.*?)</td>},
				   "about"  => %r{about:</td><td>(.*?)</td>},
		}

		user_info = request(user_url)
		created = user_info.match(regexps["created"])[1]
		@karma = user_info.match(regexps["karma"])[1]
		@avg = user_info.match(regexps["avg"])[1]
		@about = user_info.match(regexps["about"])[1]

		@create_date = time_to_day(created)
	end
end
