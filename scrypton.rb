#coding:utf-8
require 'watir'

module Scrypton
  module_function

  def browser type=:chrome
    @browser ||= Watir::Browser.new type
  end

  def close
    @browser.close if @browser.is_a? Watir::Browser
  end

  def quick_timeout num=10
    Watir.default_timeout = num
  end

  def default_timeout
    Watir.default_timeout = 30
  end

  def query_baidu keyword, interval=3
    @browser.goto 'https://www.baidu.com/'
    input = @browser.text_field(id: 'kw')
    input.set keyword

    button = @browser.button(value: '百度一下')
    button.click

    sleep interval
    return @browser
  end

  def query_bing keyword, interval=3
    @browser.goto 'https://cn.bing.com/'
    input = @browser.text_field(id: 'sb_form_q')
    input.set keyword
    sleep interval

    # 1. direct click
    # button = @browser.input(id: 'sb_form_go')
    # button.click

    # 2. bypass select
    item = @browser.ul(class: 'sa_drw').li(class: 'sa_sg', query: keyword.gsub(' ',''))
    item.click

    sleep interval
    return @browser
  end

  def query_github keyword, interval=3
    option = {"type"=> 'repositories', "page"=> 1}.merge keyword
    parameters = "q=#{option["word"]}&type=#{option["type"]}&p=#{option["page"]}"
    @browser.goto "https://github.com/search?#{parameters}"

    sleep interval
    return@browser
  end

end