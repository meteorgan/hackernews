#!/usr/bin/env ruby

require "open-uri"
require 'date'

class UserInfo
	attr_reader :user_id, :create_date, :karma, :avg, :submission_ids, :comments_id

	def initialize(user_id)
		@user_id = user_id
	end

	def get_user_info
		user_url = "https://news.ycombinator.com/user?id=" + @user_id
		regexps = {"created"=> %r{created:</td><td>(\d+) days ago},
			       "karma"  => %r{karma:</td><td>(\d+)},
				   "avg"    => %r{avg:</td><td>(.*?)</td>},
				   "about"  => %r{about:</td><td>(.*?)</td>},
		}

		user_info = request(user_url)
		created = user_info.scan(regexps["created"])[0][0]
		@karma = user_info.scan(regexps["karma"])[0][0]
		@avg = user_info.scan(regexps["avg"])[0][0]
		@about = user_info.scan(regexps["about"])[0][0]

		@create_date = Date.today - created.to_i
	end

	def get_submissions	
		submissons_url = "https://news.ycombinator.com/submitted?id=" + @user_id
		result = request(submissions_url)
		
	     @submissions_ids = result.match(%r{item\?id=(\d+)})[1..-1]	
	end

	def get_comments
		comments_url = "https://news.ycombinator.com/threads?id=" + @user_id
		result = request(submissions_url)

		@comments_ids = result.match(%r{user\?id=#{@user_id}.*?item\?id=(\d+)})[1..-1]
	end

	private
	def request(url)
		result = ''
		open(url) {|f|
			result = f.read
		}
		result
	end
end
