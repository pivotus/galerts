require 'mechanize'

module Galerts
  class Manager
    def initialize(email, password)
      @email = email
      @password = password
      init_agent
      login
    end

    def init_agent
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Linux Mozilla'
      @agent.keep_alive = true
      @agent.redirect_ok = true
      @agent.follow_meta_refresh = true
    end

    def login
      response = @agent.get(LOGIN_URL) # get login page
      login_form = Nokogiri::HTML(response.body, nil, 'utf-8').css('form#gaia_loginform input') # get login form
      params = get_login_form_params(login_form) # fetch form parameters and edit
      response = @agent.post(LOGIN_URL, params) # do login
      error = response.parser.css('span[id^=errormsg]')
      unless error.empty?
        raise error.text.delete("\n").strip
      end
    end

    def get_login_form_params(login_form)
      params = {}
      login_form.each do |input|
        if input['name'] == 'Email'
          params[input['name']] = @email
        elsif input['name'] == 'Passwd'
          params[input['name']] = @password
        else
          params[input['name']] = input['value']
        end
      end
      return params
    end

    def alerts_page
      Nokogiri::HTML(@agent.get(ALERTS_URL).body, nil, 'utf-8')
    end

    def alerts
      result = []
      contents = alerts_page.css('div#gb-main div.main-page script').text

      contents = contents.gsub('null', 'nil')

      contents = eval(contents.gsub("window.STATE = ", ""))

      # only 'id, search_query, feed_url, data_id' variables have true value,
      # other variables have default Alert class values.
      contents[1][1].each do |alert|
        result << Alert.new(alert[2][3][1], {
          id:           alert[2].last.last.last,
          search_query: alert[2][3][1],
          feed_url:     "/alerts/feeds/#{alert.last}/#{alert[2].last.last.last}",
          data_id:      alert[1],
          domain:       'Unknown',
          frequency:    'Unknown',
          sources:      'Unknown',
          language:     'Unknown',
          how_many:     'Unknown',
          region:       'Unknown',
          delivery:     'Unknown'
          }
        )
      end
      result
    end

    def build_create_params(search_query, options)
      # check parameters
      raise "Unknown alert how_many" unless HOW_MANY_TYPES.has_key?(options[:how_many])
      raise "Unknown alert delivery type" unless DELIVERY_TYPES.include?(options[:delivery])
      raise "Unknown alert frequency type" unless FREQ_TYPES.include?(options[:frequency])

      # set delivery and frequency parameters
      if options[:delivery] == EMAIL
        if options[:frequency] == DAILY
          delivery_and_frequency = @email + ',[null,null,11],2'
        elsif options[:frequency] == WEEKLY
          delivery_and_frequency = @email + ',[null,null,11,1],3'
        elsif options[:frequency] == RT
          delivery_and_frequency = "1,\"#{@email}\",[],1"
        end
      elsif options[:delivery] == RSS
        delivery_and_frequency = "2,\"\",[],1"
      end

      # options[:sources] ? sources = options[:sources] : sources = ""

      if options[:sources].nil?
        sources_text = 'null'
      else
        sources_text = "["
        options[:sources].collect do |source|
          raise "Unknown alert source" unless SOURCES_TYPES.has_key?(source)
          sources_text += SOURCES_TYPES[source].to_s + ','
        end
        sources_text = sources_text.chop + ']'
      end

      # TODO: need more readable
      params = {
        'params' => "[null,[null,null,null,[null,\"#{search_query}\",\"#{options[:domain]}\",[null,\"#{options[:language]}\",\"#{options[:region]}\"],null,null,null,#{options[:region] == "" ? 1 : 0},1],#{sources_text},#{HOW_MANY_TYPES[options[:how_many]]},[[null,#{delivery_and_frequency},\"#{options[:language] + '-' + options[:region].upcase}\",null,null,null,null,null,'0']]]]"
      }

      params = URI.encode_www_form(params)
    end

    def create(search_query, options = {})
      x = alerts_page.css('div#gb-main div.main-page script').text.split(',').last[1..-4]
      response = @agent.post("#{CREATE_ALERT_URL}x=#{x}", build_create_params(search_query, options), {'Content-Type' => 'application/x-www-form-urlencoded'})

      if response.body == ALERT_EXIST
        raise "Alert exist!"
      elsif response.body == ALERT_SOMETHING_WENT_WRONG
        raise "Something went wrong!" # internal error, html changed maybe
      else
        response_body = response.body.gsub('null', 'nil')
        created_alert = Nokogiri::HTML(eval(response_body)[4][0][2], nil, 'utf-8')

        alert = Alert.new(search_query, options)

        if options[:delivery] == RSS
          alert.id = created_alert.css('a')[0]['href'].split('/').last if options[:delivery] == RSS
          alert.feed_url = created_alert.css('a')[0]['href']
        end
        alert.data_id = created_alert.css('li')[0]['data-id']
        alert
      end
    end
  end
end
