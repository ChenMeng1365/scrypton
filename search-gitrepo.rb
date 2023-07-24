#coding:utf-8
require 'json'
require_relative 'scrypton'

# 扩展: 仓库列表查询
module Scrypton
  module_function

  def github_repolist
    repolist = []
    begin
      (0..9).each do|index|
        link = @browser.a(class: 'v-align-middle', index: index).href
        repolist << link
      end
      File.write '1.txt', @browser.html
    rescue Watir::Exception::UnknownObjectException => out_of_item
      # puts out_of_item.message
    end
    return repolist
  end
end


Scrypton.quick_timeout
Scrypton.browser

Dir.mkdir 'doc' unless File.exist? 'doc'

begin # 查询
  keyword = JSON.parse DATA.read.gsub("\r","").gsub("\n","")
  repolist = (1..9).inject([])do|repolist, pidx|
    Scrypton.query_github keyword.merge("page"=>pidx)
    repolist + Scrypton.github_repolist
  end
  File.write "doc/git-repos.txt", repolist.join("\n")
end


__END__
{"word": "KEYWORD", "type": "repositories", "page": "NUM"}