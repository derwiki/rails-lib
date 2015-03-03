require 'open-uri'
require 'nokogiri'

module Seo
  class << self
    def google_serp(q)
      [[], []].tap do |organic, paid|
        start = [0, 10, 20, 30, 40, 50]
        start.each do |offset|
          url = "http://www.google.com/search?q="\
                "#{ URI::encode(q) }&start=#{ offset }"
          doc = Nokogiri::HTML(open(url))

          doc.css('li.g h3 a').each_with_index do |result, i|
            raw_href = result.attribute('href').value
            href = raw_href.match(/adurl=(.*?)(%3F|&)/).try(:[], 1)
            href = raw_href.match(/q=(.*?)&/)[1] if href.blank?
            organic << { rank: i + offset, href: href, title: result.text }
          end

          doc.css('#rhs_block li h3 a').each_with_index do |result, i|
            raw_href = result.attribute('href').value
            href = raw_href.match(/adurl=(.*?)(%3F|&)/).try(:[], 1)
            href = raw_href.match(/q=(.*?)&/)[1] if href.blank?
            paid << { rank: i, href: href, title: result.text }
          end
        end
      end
    end

    # SEO report functions
    def get_title(url)
      m(url).css('title').first.try(:content)
    end

    def get_meta_description(url)
      m(url).css('meta[name="description"]').first.try(:[], :content)
    end

    def get_h1(url)
      m(url).css('h1').first.try(:content)
    end

    # `m` for memoize
    def m(url, pattern=nil)
      @cache ||= {}
      if (payload = @cache[url]).present?
        payload
      else
        payload = @cache[url] = Nokogiri::HTML(open(url))
      end
    end
  end
end
