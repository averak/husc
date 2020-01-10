Crawler
=======

Script for crawling in Ruby


## Description
This project enables site crawling and data extraction with xpath and css selectors. You can also send forms such as text data, files, and checkboxes.


## Requirement

- Ruby 2.3 or above


## Usage
### Simple Example
```ruby
require './rbcrawl.rb'

url = 'http://www.example.com/'
doc = RbCrawl.new(url)

# Search for nodes by css
doc.css('div')
doc.css('.main-text')
doc.css('#tadjs')

# Search for nodes by xpath
doc.xpath('//*[@id="top"]/div[1]')

# Others
doc.css('div').css('a')[2].attr('href')
doc.css('p').innerText()
doc.tables  # -> Table Tag to Dict

# You do not need to specify "[]" to access the first index
```


## Installation
```sh
$ gem install husc
```