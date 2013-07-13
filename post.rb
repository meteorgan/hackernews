#!/usr/bin/env ruby

require "utils"

class Post
	attr_reader :item_id, :score, :committer, :title, :url, :created_date

	def initialize(item_id, comment=false)
		@item_id = item_id
		post_url = "https://news.ycombinator.com/item?id=" + item_id.to_s
		@content = request(post_url)
	end

	def has_comments?
		regexp = %r{<a href="item?id=#{@item_id}">(.*?)</a>}
		result = @content.match(regexp)[1]
		return (result == "comments")
	end

	def get_comments
		# all comments of the post including the comments of comments.
		if has_comments?
			regexp = %r{}
		end
	end

	private
	def get_post_info
		score_id = "score_id" + @item_id.to_s
		regexps = {"score_committer_date" => %r{id=#{score_id}>(.*?) points </span> by <a href="user\?id=(.*?)">(.*?)</a> (.*?) ago},
			       "title_url" => %r{<td class="title"><a href="(.*?)">(.*?)</a>},
		}

		@score, @committer, time = @content.match(regexps["score_committer_date"])[1..-1]
		@title, @url = @content.match(regexps["title_url"])[1..-1]

		@created_date = time_to_date(time)
	end
end
