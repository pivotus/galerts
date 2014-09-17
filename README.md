#   Galerts

Simple Ruby library that uses Mechanize to scrape Google Alerts from the google
alerts webpage.

##  Features

-   List all alerts associated with account.
-   Create new alert for any google domain.
-   Delete an alert
-   Find alerts by query, id, data_id, feed_url, domain, language, how_many,
    region, delivery

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

#   Delete an alert with alerts data_id
manager.delete("alerts data_id")

#   Find examples
manager.find_by_query("keyword")
manager.find_by_delivery(Galerts::RSS)
manager.find({query: "keyword", delivery: Galerts::RSS})
```

##  Contribute

I need your contributions to make that work better!

##  License

This project licensed under MIT.
