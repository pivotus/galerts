module Galerts
  # URLs
  CREATE_ALERT_URL = 'https://www.google.com/alerts/create?'
  DELETE_ALERT_URL = 'https://www.google.com/alerts/delete?'
  MODIFY_ALERT_URL = 'https://www.google.com/alerts/modify?'
  GOOGLE_LOGIN_URL = 'https://accounts.google.com/ServiceLogin?'
  ALERTS_URL = 'https://www.google.com/alerts'
  LOGIN_URL = "#{GOOGLE_LOGIN_URL}service=alerts&continue=#{ALERTS_URL}"

  # Google Return HTML Definitions
  ALERT_EXIST       = "[null,11,null,\"\"]"
  ALERT_SOMETHING_WENT_WRONG = "[null,7,null,\"\"]"
  ALERT_NOT_EXIST = "[null,5,null,\"\"]"
  # Google Value
  BEST_RESULTS = 'Only the best results'
  ALL_RESULTS = 'All results'

  HOW_MANY_TYPES = {
    ALL_RESULTS  => 2,
    BEST_RESULTS => 3
  }

  RSS = 'rss'
  EMAIL = 'email'

  DELIVERY_TYPES = {
    EMAIL => 1,
    RSS => 2
  }


  RT = 'As it happens'
  DAILY = 'Once a day'
  WEEKLY = 'Once a week'

  FREQ_TYPES = {
    RT => 1,
    DAILY => 2,
    WEEKLY => 3
  }


  BLOGS = 'Blogs'
  NEWS = 'News'
  WEB = 'Web'
  VIDEOS = 'Videos'
  BOOKS = 'Books'
  DISCUSSIONS = 'Discussions'

  SOURCES_TYPES = {
    BLOGS => 1,
    NEWS => 2,
    WEB => 3,
    VIDEOS => 5,
    BOOKS => 6,
    DISCUSSIONS => 7
  }
end

require File.expand_path('../galerts/alert', __FILE__)
require File.expand_path('../galerts/manager', __FILE__)
require File.expand_path('../galerts/version', __FILE__)


