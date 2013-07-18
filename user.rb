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
        @submissions
    end

    def get_submissions
        # notice: there is "more" in the webpage!
        submissions_url = "https://news.ycombinator.com/submitted?id=" + @user_id
        @submissions = []

        number = 0
        while submissions_url
            r = get_submission_info_from_page(submissions_url)
            unless r
                return false
            end
            @submissions.push(*r)
            submissions_url = get_more(submissions_url)
            number += 1
            puts number
        end
        @submissions
    end

    def get_comments
    end

    def get_submission_ids
        submission_ids  = []
        if @submissions
            submission_ids = @submissions.collect {|submission| submission[2]}
            return submission_ids
        end

        submissions_url = "https://news.ycombinator.com/submitted?id=" + @user_id
        while submissions_url
            r = get_submission_ids_from_page(submissions_url)
            unless r
                return false
            end
            submission_ids.push(*r)
            submissions_url = get_more(submissions_url)
        end
        submission_ids
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
        unless user_info
            print "url request error ", user_url
            return false
        end
        created = user_info.match(regexps["created"])[1]
        @karma = user_info.match(regexps["karma"])[1]
        @avg = user_info.match(regexps["avg"])[1]
        @about = user_info.match(regexps["about"])[1]

        @create_date = time_to_date(created)
    end

    def get_submission_info_from_page(url)
        content = request(url)
        unless content
            print "get submissions error ", url
            return false
        end

        regexp = %r{<td class="title"><a href="(.*?)">(.*?)</a>(.*?)</td></tr><tr><td colspan=2></td><td class="subtext"><span id=score_(\d+)>(\d+) points?</span> by <a href="user\?id=#{@user_id}">#{@user_id}</a> (.*?) ago  \| <a href="item\?id=(\d+)">(.*?)</a>}

        info = content.scan(regexp)
        result = info.collect {|submission|
            url, title, _, item_id, score, dt, _, comments = submission
            unless comments
                puts @user_id, url
                next
            end

            if url =~ / rel/
                url  = $`.chop
            end
            unless url.start_with?("http")
                url = URI.join("https://news.ycombinator.com/", url).to_s
            end

            item_id = item_id.to_i
            score = score.to_i
            date = time_to_date(dt)

            comments_number = 0
            if comments == "comments"
                comments_number = -1
            elsif comments =~ /comments/
                comments_number = comments.split()[0].to_i
            end

            arr = [url, title, item_id, score, date, comments_number]
            puts arr.to_s
            arr
        }
    end

    def get_submission_ids_from_page(url)
        result = request(url)
        unless result
            print "get submission error ", url
            return false
        end
        regexp = %r{ago  \| <a href="item\?id=(\d+)}

        result.scan(regexp).flatten(1)
    end

    def get_more(url)
        regexp = %r{<a href="/x\?fnid=(.*?)" rel="nofollow">More</a>}
        content = request(url)
        unless content
            print "get more page error ", url
            return false
        end
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
