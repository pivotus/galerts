#   Galerts

Simple Ruby library that uses Mechanize to scrape Google Alerts from the google
alerts webpage.

##  Features

-   List all alerts associated with account.
-   Create new alerts for any google domain.

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
```

##  Contribute

I need your contributions to make that work better!

##  License

This project licensed under MIT.
