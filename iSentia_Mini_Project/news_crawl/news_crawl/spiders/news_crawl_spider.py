from scrapy import Request
from scrapy.spider import Spider
from scrapy.selector import Selector
from news_crawl.items import NewsCrawlItem

class NewsCrawlSpider(Spider):
### Base Spiderclass Config ###
    name = "news_crawl"
    allowed_domains = ["theguardian.com"]
    start_urls = ["https://www.theguardian.com/au"]

### Parsing Function to scrape list of the news articles theguardian.com/au from Homepage ###
    def parse(self, response):
        elements = Selector(response).xpath('//div[@class="fc-item__header"]')
        for element in elements:
            article_title = element.xpath('.//span[@class="fc-item__kicker"]/text()').extract_first()
            article_headline = element.xpath('.//span[@class="js-headline-text"]/text()').extract_first()
            article_url = element.xpath('.//a/@href').extract_first()
            yield Request(str(article_url), callback=self.parse_article_page, meta={'title': article_title, 'headline': article_headline, 'url': article_url})

### Parsing Function to navigate the to individual article page to scrape author details & article body ###
    def parse_article_page(self, response):
        item = NewsCrawlItem()
        item['article_title'] = response.meta.get('title')
        item['article_headline'] = response.meta.get('headline')
        item['article_url'] = response.meta.get('url')
        article_author = Selector(response).xpath('//div[@class="meta__contact-wrap"]')
        if not article_author:
            article_author = Selector(response).xpath('//div[@class="u-cf"]')
        for author in article_author:
            item['article_author'] = author.xpath('.//span[@itemprop="name"]/text()').extract_first()
        article_body = Selector(response).xpath('//div[@class="content__article-body from-content-api js-article__body"]')
        for body in article_body:
            item['article_body'] = body.xpath('.//p/text()').extract_first()
        yield item
