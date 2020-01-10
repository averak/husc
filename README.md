husc
====

A simple crawling utility for Ruby.


## Description
This project enables site crawling and data extraction with xpath and css selectors. You can also send forms such as text data, files, and checkboxes.


## Requirement

- Ruby 2.3 or above


## Usage
### Simple Example
```ruby
require 'husc'

url = 'http://www.example.com/'
doc = Husc.new(url)

# access another url
doc.get('another url')

# get current url
doc.url

# get current site's html
doc.html

# get <table> tags as dict
doc.tables
```

### Scraping Example
```ruby
# search for nodes by css selector
# tag   : css('name')
# class : css('.name')
# id    : css('#name')
doc.css('div')
doc.css('.main-text')
doc.css('#tadjs')

# search for nodes by xpath
doc.xpath('//*[@id="top"]/div[1]')

# other example
doc.css('div').css('a')[2].attr('href') # => string object
doc.css('p').inner_text() # => string object
# You do not need to specify "[]" to access the first index
```

### Submitting Form Example
1. Specify target node's attribute
2. Specify value(int or str) / check(bool) / file_name(str)
3. Call submit() with form attribute specified
```ruby
# login
doc.send(id:'id attribute', value:'value to send')
doc.send(id:'id attribute', value:'value to send')
doc.submit(id:'id attribute') # submit

# post file
doc.send(id:'id attribute', file_name:'target file name')

# checkbox
doc.send(id:'id attribute', check:True)  # check
doc.send(id:'id attribute', check:False) # uncheck

# example of specify other attribute
doc.send(name:'name attribute', value:'hello')
doc.send(class:'class attribute', value:100)
```


## Installation
```sh
$ gem install husc
```


## Contributing
Bug reports and pull requests are welcome on GitHub at [https://github.com/AjxLab/husc](https://github.com/AjxLab/husc).
