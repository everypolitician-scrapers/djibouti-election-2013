#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//p[contains(.,"Waakan Magacayadii")]//following-sibling::p').map(&:text).each do |li|
    li.sub!(' 9UMP', '(UMP')
    cap = li.match(/^(\d+)\.?\s*(.*?)\s*\((.*?)[.,\s]+(.*?)\)/) or break

    data = {
      name:   cap[2],
      party:  cap[3].upcase,
      area:   cap[4],
      term:   6,
      source: url,
    }
    data[:area] = 'Obock' if data[:area] == 'Ubock'
    ScraperWiki.save_sqlite(%i(name area), data)
  end
end

scrape_list('http://www.lughaya.com/archives/19857')
