#!/usr/bin/env ruby

require "./utils"

def comments_parser(url)
    content = request(url)
    unless content
        print "error: ", url
    end

    # m to match '\n'
    comments_tables = content.scan(%r{<table border=0>(.*?)</table>}m)[0...-1]

    stack = []
    comments = Hash.new    # user name, comment time, parent comment(article) id, parent content, comment content, children comments
    children = Hash.new    # user name, comment time, parent comment id, comment content, children comments
    comments_tables.each {|table|
        info = table[0]
        width = info.match(%r{width=(\d+)})[1].to_i
        seq = width/40
        stack = stack[0...seq]     # commend id, using for getting parent comment id
        if seq == 0
            regexp = %r{<a href="user\?id=(.*?)">(.*?)</a> (.*?) ago  \| <a href="item\?id=(\d+)">link</a> \| <a href="item\?id=(\d+)">parent</a> \| on: <a href="item\?id=(\d+)">(.*?)</a></span></div><br>\n<span class="comment"><font color=#000000>(.*?)</font>}m
            user, _, t, comment_id, parent_id, _, parent_content, comment = info.match(regexp)[1..-1]
            date = time_to_date(t)
            comments[comment_id] = [user, date, parent_id, parent_content, comment, []]
        else
            regexp = %r{<a href="user\?id=(.*?)">(.*?)</a> (.*?) ago  \| <a href="item\?id=(\d+)">link</a></span></div><br>\n<span class="comment"><font color=#.*?>(.*?)</font>}m
            user, _, t, comment_id, comment = info.match(regexp)[1..-1]
            parent_id = stack.last
            date = time_to_date(t)
            children[comment_id] = [user, date, parent_id, comment, []]
            if seq != 1
                children[parent_id][4] << children[comment_id]
            end
        end

        stack << comment_id
    }

    comments_ids = comments.keys
    children.each {|key, value|
        parent_id = value[2]
        if comments_ids.include?(parent_id)
            comments[parent_id][5] << children[key]
        end
    }

    return comments
end
