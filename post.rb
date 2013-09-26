#!/usr/bin/env ruby

require "./utils"
require "./comments_parser"

class Post
    attr_reader :item_id, :score, :committer, :title, :url, :created_date

    def initialize(item_id)
        @item_id = item_id
        @post_url = "https://news.ycombinator.com/item?id=" + @item_id.to_s
        @content = request(@post_url)
        get_post_info
    end

    def has_comments?
        regexp = %r{<a href="item\?id=#{@item_id}">(.*?)</a>}
        result = @content.match(regexp)[1]
        return (result.include?("comments"))
    end

    def get_comments
        # all comments of the post including the comments of comments.
        @comments = []
        if has_comments?
            @comments = comments_parser
        end
        @comments
    end

    private
    def get_post_info
        score_id = "score_" + @item_id.to_s
        regexps = {"score_committer_date" => %r{id=#{score_id}>(.*?) points</span> by <a href="user\?id=(.*?)">(.*?)</a> (.*?) ago},
                   "title_url" => %r{<td class="title"><a href="(.*?)">(.*?)</a>},
        }

        @score, @committer, _, time = @content.match(regexps["score_committer_date"])[1..-1]
        @score = @score.to_i
        @title, @url = @content.match(regexps["title_url"])[1..-1]

        @created_date = time_to_date(time)
    end

    def comments_parser
        comments_tables = @content.scan(%r{<table border=0>(.*?)</table>}m)[1..-1]

        stack = []
        comments = Hash.new    # user name, comment time, parent comment(article) id, parent content, comment content, children comments
        top_comments_id = []
        comments_tables.each {|table|
            info = table[0]
            width = info.match(%r{width=(\d+)})[1].to_i
            seq = width/40
            stack = stack[0...seq]     # comment id, using for getting parent comment id

            regexp = %r{<a href="user\?id=(.*?)">(.*?)</a> (.*?) ago  \| <a href="item\?id=(\d+)">link</a></span></div><br>\n<span class="comment"><font color=#.*?>(.*?)</font>}m
            user, _, t, comment_id, comment = info.match(regexp)[1..-1]
            parent_id = stack.last
            date = time_to_date(t)

            comments[comment_id] = [user, date, parent_id, comment, []]
            if parent_id
                comments[parent_id][4] << comments[comment_id]
            else
                top_comments_id << comment_id
            end

            stack << comment_id
        }


        comments.delete_if {|key, value| !top_comments_id.include?(key)}
    end
end
