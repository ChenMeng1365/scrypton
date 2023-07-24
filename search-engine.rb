#coding:utf-8
require 'json'
require_relative 'scrypton'

# 引擎查询: 关键字查询
module Scrypton
  module_function

  def scjg_articles all=100
    articles, index = [], 0
    all.times.each do
      (1..10).each do|id|
        begin
          alink = @browser.div(class: 'result c-container xpath-log new-pmd', id: "#{index*10+id}").a(tabindex: '0')
          articles << alink.href
        rescue Watir::Exception::UnknownObjectException => out_of_item
          # puts out_of_item.message
        end
      end
      index += 1
      begin
        next_page = @browser.div(class: 'page-inner_2jZi2').a(text: "#{index+1}")
        next_page.click
        # Scrypton.default_timeout
      rescue Watir::Exception::UnknownObjectException => out_of_page
        # puts out_of_page.message
        break
      end
    end
    return articles
  end

  def scjg_refine article
    begin
      @browser.goto article
    rescue Net::ReadTimeout => out_of_read
      sleep 3
    end
    sleep 1
    begin
      content = @browser.div(class: 'r-rest').text
    rescue Watir::Exception::UnknownObjectException => out_of_item
      # puts out_of_item.message
      content = ''
    end
    # puts [@browser.url, @browser.title, content]
    return "[#{@browser.title}](#{@browser.url})\n\n#{content}"
  end
end

Scrypton.quick_timeout
Scrypton.browser

Dir.mkdir 'doc' unless File.exist? 'doc'

begin # 查询
  keyword = DATA.read.gsub("\r","").gsub("\n","")
  Scrypton.query_baidu keyword
  articles = Scrypton.scjg_articles
  File.write "doc/scjg-articles.json", JSON.pretty_generate(articles)
end

begin # 摘要
  articles = JSON.parse File.read "doc/scjg-articles.json"
  digests = articles.inject([]){|digests,article|digests << (Scrypton.scjg_refine article)}
  File.write "doc/digest.md", digests.join("\n\n---\n\n")
end

Scrypton.close

__END__
KEYWORD site:DOMAIN