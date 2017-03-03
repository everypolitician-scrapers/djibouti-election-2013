#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

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
    # puts data.reject { |k, v| v.to_s.empty? }.sort_by { |k, v| k }.to_h
    ScraperWiki.save_sqlite(%i(name area), data)
  end
end

scrape_list('http://www.lughaya.com/archives/19857')
