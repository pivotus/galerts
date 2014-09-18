#   Galerts

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

#   Create a new alert for on Google News Turkey in real time delivering alerts
#   via RSS
manager.create("my keywords", {
  :frequency => Galerts::RT,
  :domain => 'com.tr',
  :language => "tr",
  :sources => [Galerts::NEWS],
  :how_many => Galerts::ALL_RESULTS,
  :region => "TR",
  :delivery => Galerts::RSS
  }
)

alert = manager.alerts.last

#   Update the query of this alert
alert.query = "updated keyword"
manager.update(alert)

#   Find examples
manager.find_by_query("keyword")
manager.find_by_delivery(Galerts::RSS)
manager.find({query: "keyword", delivery: Galerts::RSS})

#   Delete an alert with alerts data_id
manager.delete("alerts data_id")

```

##  Contribute

I need your contributions to make that work better!

##  License

This project licensed under MIT.
