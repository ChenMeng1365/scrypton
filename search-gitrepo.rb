#coding:utf-8
$:<<'.'
eval(DATA.read)

begin # 查询
  Scrypton.quick_timeout
  Scrypton.browser
  Dir.mkdir 'doc' unless File.exist? 'doc'

  field = YAML.load File.read('github.fields.yml') # EDIT THIS FILE FOR EACH SEARCHING!
  instances = [field['ref'], field['des'], field['dig']]
  start  = (field['start'] || '1').to_i
  finish = (field['finish']|| '3').to_i
  keyword = JSON.parse '{"word": "KEY", "type": "repositories", "page": "NUM"}'
  repolist = (start..finish).inject([])do|repolist, pidx|
    Scrypton.query_github keyword.merge("page"=>pidx, "word"=>field['key'].gsub(" ","+").gsub(":","%3A"))
    repolist + Scrypton.github_repolist(instances)
  end
  File.open("doc/git-repos-dig.txt","a+"){|file|file.write repolist.join("\n")+"\n"}
end

__END__
require 'yaml'
require 'json'
require 'scrypton'

# 扩展: 仓库列表查询
module Scrypton
  module_function

  def github_repolist instances # := [0: link-reference, 1: description, 2: digest(language,stars,date)]
    repolist = []

    (0..9).each do|index|
      begin
        link = @browser.a(class: instances[0], index: index).href
        desc = @browser.span(class: instances[1], index: index).text
        ul_id, li_id, span_id = instances[2].split(',')
        begin
          lang = @browser.ul(class: ul_id, index: index).li(class: li_id, index: 0).span(class: span_id).text
        rescue
          lang = ''
        end
        # star = @browser.a(class: instances[3], index: index).text
        begin
          star = @browser.ul(class: ul_id, index: index).li(class: li_id, index: 1).span(class: span_id).text
        rescue
          star = ''
        end
        begin
          date = @browser.ul(class: ul_id, index: index).li(class: li_id, index: 2).span(class: span_id).text
        rescue
          date = ''
        end
        repolist << [link, desc, lang, star, date.gsub("Updated on ","").gsub("Updated ","")].join("\t")
      rescue Watir::Exception::UnknownObjectException => out_of_item
        puts link, out_of_item.message
      end
    end
    return repolist
  end
end