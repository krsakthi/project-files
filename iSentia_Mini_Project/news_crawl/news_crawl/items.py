# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy.item import Item, Field

class NewsCrawlItem(Item):
# define the fields for the item:
    article_url = Field()
    article_title = Field()
    article_author = Field()
    article_body = Field()
    article_headline = Field()


