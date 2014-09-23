#   Galerts

[![Gem Version](https://badge.fury.io/rb/galerts.png)][gem]
[![Build Status](https://secure.travis-ci.org/pivotus/galerts.png?branch=master)][travis]

[gem]: http://badge.fury.io/rb/galerts
[travis]: http://travis-ci.org/pivotus/galerts

Simple Ruby library that uses Mechanize to scrape Google Alerts from the google
alerts webpage.

##  Features

-   List all alerts associated with account.
-   Create new alert for any google domain.
-   Update existing alert.
-   Delete an alert.
-   Find alerts by query, id, data_id, feed_url, domain, language, how_many,
    region, delivery.

##  Installation

```sh
gem install galerts
```

##  Example

```ruby
require 'google_alerts'

manager = Galerts::Manager.new('example@gmail.com', 'password')

#   List alerts
alerts = manager.alerts
sample_alert = alerts.last

#   Create a new alert for on Google News Turkey in real time delivering alerts
#   via RSS
new_alert = manager.create("my keywords", {
  :frequency => Galerts::RT,
  :domain => 'com.tr',
  :language => "tr",
  :sources => [Galerts::NEWS],
  :how_many => Galerts::ALL_RESULTS,
  :region => "TR",
  :delivery => Galerts::RSS
  }
)

#   Update the query of this alert
sample_alert.query = "updated keyword"
manager.update(sample_alert)

#   Find examples
manager.find_by_query("keyword")
manager.find_by_delivery(Galerts::RSS)
manager.find({query: "keyword", delivery: Galerts::RSS})

#   Delete an alert
manager.delete(sample_alert)

```

##  Contribute

I need your contributions to make that work better!

##  License

This project licensed under MIT.
