#!/usr/bin/env ruby

require "./utils"

def comments_parser(url)
   content = request(url)
   unless url
       print "error: ", url
   end

   tables = content.scan(%r{<table border=0>(.*?)</table>}m)
end

