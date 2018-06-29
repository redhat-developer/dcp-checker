# Dcp::Checker

## Installation

Add the following to your Gemfile

```ruby
gem 'dcp-checker', :git => 'http://github.com/redhat-developer/rhd-dcp-checker'
```

And then execute:

    $ bundle install

## Usage

The aim of this gem is to test from broken links within red hat developer content.

## Development

After checking out the repo, run `bundle exec rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Config
By default dcp-checker will check for the following:

      - jbossdeveloper_quickstart
      - jbossdeveloper_demo
      - jbossdeveloper_bom
      - jbossdeveloper_archetype
      - jbossdeveloper_example
      - jbossdeveloper_vimeo
      - jbossdeveloper_youtube
      - jbossdeveloper_book
      - jbossdeveloper_event
      - jbossdeveloper_cheatsheet
      - rht_website
     
You can customise the content types by adding `config/dcp-config.yml` to the directory where you are executing checks from

     - jbossdeveloper_quickstart
     - new_content_type1
     - new_content_type2
     - new_content_type3


