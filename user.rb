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
        submissions_url = "https://news.ycombinator.com/submitted?id=" + @user_id
        puts get_submission_info_from_page(submissions_url)
    end

    def comments
    end

    def submission_ids
        submissions_url = "https://news.ycombinator.com/submitted?id=" + @user_id
        @submission_ids  = []

        while submissions_url
            @submission_ids << get_submission_ids_from_page(submissions_url)
            submissions_url = get_more(submissions_url)
        end
        @submissions
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

        @create_date = time_to_date(created)
    end

    def get_submission_info_from_page(url)
        result = request(url)
        regexp = %r{<td class="title"><a href="(.*?)" rel="nofollow">(.*?)</a><span class="comhead"> (.*?) </span></td></tr><tr><td colspan=2></td><td class="subtext"><span id=score_(\d+)>(\d+) points</span> by <a href="user\?id=#{@user_id}">#{@user_id}</a> (.*?) ago  \| <a href="item\?id=(\d+)">(.*?)</a>}

        result.scan(regexp)
    end

    def get_submission_ids_from_page(url)
        result = request(url)
        regexp = %r{ago  \| <a href="item\?id=(\d+)}

        result.scan(regexp).flatten(1)
    end

    def get_more(url)
        regexp = %r{<a href="/x\?fnid=(.*?)" rel="nofollow">More</a>}
        content = request(url)
        matches = content.match(regexp)
        if matches
            path = matches[1]
            puts "more page: " + path
            return "https://news.ycombinator.com/x?fnid=" + path
        else
            puts content
        end
    end
end
