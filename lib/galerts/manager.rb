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
      @agent.open_timeout=10
      @agent.read_timeout=10
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

      if contents[1]
        contents[1][1].each do |alert|
          result << Alert.new(alert[2][3][1], {
            id:           alert[2][6][0][11],
            query: alert[2][3][1],
            feed_url:     "#{ALERTS_URL}/feeds/#{alert.last}/#{alert[2][6][0][11]}",
            data_id:      alert[1],
            data_id_2:    alert[2][6][0].last,
            domain:       alert[2][3][2],
            language:     alert[2][3][3][1],
            region:       alert[2][3].last == 1 ? alert[2][3][3][2] : ANYWHERE,
            frequency:    FREQ_TYPES.invert[alert[2][6][0][4]],
            sources:      SOURCES_TYPES.invert[alert[2][4]],
            how_many:     HOW_MANY_TYPES.invert[alert[2][5]],
            delivery:     DELIVERY_TYPES.invert[alert[2][6][0][1]]
          })
        end
      end
      result
    end

    def build_params(alert, action)
      # set delivery and frequency parameters
      if alert.delivery == EMAIL
        if alert.frequency == DAILY
          delivery_and_frequency = "#{DELIVERY_TYPES[EMAIL]},\"#{@email}\",[null,null,11],#{FREQ_TYPES[DAILY]}"
        elsif alert.frequency == WEEKLY
          delivery_and_frequency = "#{DELIVERY_TYPES[EMAIL]},\"#{@email}\",[null,null,11,1],#{FREQ_TYPES[WEEKLY]}"
        elsif alert.frequency == RT
          delivery_and_frequency = "#{DELIVERY_TYPES[EMAIL]},\"#{@email}\",[],#{FREQ_TYPES[RT]}"
        end
      elsif alert.delivery == RSS
        delivery_and_frequency = "#{DELIVERY_TYPES[RSS]},\"\",[],#{FREQ_TYPES[RT]}"
      end

      if alert.sources.empty?
        sources_text = 'null'
      else
        sources_text = "["
        alert.sources.collect do |source|
          raise "Unknown alert source" unless SOURCES_TYPES.has_key?(source)
          sources_text += SOURCES_TYPES[source].to_s + ','
        end
        sources_text = sources_text.chop + ']'
      end

      if alert.region == ANYWHERE
        region = REGION
        anywhere = true
      else
        region = alert.region
        anywhere = false
      end

      # TODO: need more readable
      if action == 0 # create
        params = {
          'params' => "[null,[null,null,null,[null,\"#{alert.query}\",\"#{alert.domain}\",[null,\"#{alert.language}\",\"#{region}\"],null,null,null,#{anywhere ? 0 : 1},1],#{sources_text},#{HOW_MANY_TYPES[alert.how_many]},[[null,#{delivery_and_frequency},\"#{alert.language + '-' + region.upcase}\",null,null,null,null,null,'0',null,null,\"#{alert.data_id_2}\"]]]]"
        }
        return URI.encode_www_form(params)
      elsif action == 1 # edit
        params = {
          'params' => "[null,\"#{alert.data_id}\",[null,null,null,[null,\"#{alert.query}\",\"#{alert.domain}\",[null,\"#{alert.language}\",\"#{region}\"],null,null,null,#{anywhere ? 0 : 1},1],#{sources_text},#{HOW_MANY_TYPES[alert.how_many]},[[null,#{delivery_and_frequency},\"#{alert.language + '-' + region.upcase}\",null,null,null,null,null,\"#{alert.id}\",null,null,\"#{alert.data_id_2}\"]]]]"
        }
        return URI.encode_www_form(params)
      elsif action == 2 # delete
        params = {
          'params' => "[null,\"#{alert.data_id}\"]"
        }
        return URI.encode_www_form(params)
      end
    end

    def create(query, options = {})
      alert = Alert.new(query, options)

      x = alerts_page.css('div#gb-main div.main-page script').text.split(',').grep(/AMJH/).first.tr('"/\"','')
      alert.data_id_2 = alerts_page.css('div#gb-main div.main-page script').text.split(',').grep(/AB2X/).first.tr('"/\"','').tr('\]','')
      response = @agent.post("#{CREATE_ALERT_URL}x=#{x}", build_params(alert, 0), {'Content-Type' => 'application/x-www-form-urlencoded'})

      if response.body == ALERT_EXIST
        find_by_query(query).first
      elsif response.body == ALERT_SOMETHING_WENT_WRONG
        raise "Something went wrong!" # internal error, html changed maybe
      elsif response.body == ALERT_LIMIT_EXCEEDED
        raise "You have exceeded the limit of 1000 alerts per account"
      else
        response_body = response.body.gsub('null', 'nil')
        created_alert = Nokogiri::HTML(eval(response_body)[4][0][2], nil, 'utf-8')

        if options[:delivery] == RSS
          alert.id = created_alert.css('a')[0]['href'].split('/').last if options[:delivery] == RSS
          alert.feed_url = GOOGLE_URL + created_alert.css('a')[0]['href']
        end
        alert.data_id = created_alert.css('li')[0]['data-id']
        alert
      end
    end

    def update(alert)
      x = alerts_page.css('div#gb-main div.main-page script').text.split(',').grep(/AMJH/).first.tr('"/\"','')
      alert.data_id_2 = alerts_page.css('div#gb-main div.main-page script').text.split(',').grep(/AB2X/).first.tr('"/\"','').tr('\]','')
      response = @agent.post("#{MODIFY_ALERT_URL}x=#{x}", build_params(alert, 1), {'Content-Type' => 'application/x-www-form-urlencoded'})

      if response.body == ALERT_EXIST
        find_by_query(alert.query).first
      elsif response.body == ALERT_SOMETHING_WENT_WRONG
        raise "Something went wrong!" # internal error, html changed maybe
      else
        response_body = response.body.gsub('null', 'nil')
        created_alert = Nokogiri::HTML(eval(response_body)[4][0][2], nil, 'utf-8')

        if alert.delivery == RSS
          alert.id = created_alert.css('a')[0]['href'].split('/').last if alert.delivery == RSS
          alert.feed_url = GOOGLE_URL + created_alert.css('a')[0]['href']
        end
        alert.data_id = created_alert.css('li')[0]['data-id']
        alert
      end
    end

    def delete(alert)
      x = alerts_page.css('div#gb-main div.main-page script').text.split(',').grep(/AMJH/).first.tr('"/\"','')
      alert.data_id_2 = alerts_page.css('div#gb-main div.main-page script').text.split(',').grep(/AB2X/).first.tr('"/\"','').tr('\]','')
      response = @agent.post("#{DELETE_ALERT_URL}x=#{x}", build_params(alert, 2), {'Content-Type' => 'application/x-www-form-urlencoded'})

      if response.body == ALERT_NOT_EXIST
        raise "Alert not exist!"
      elsif response.body == ALERT_SOMETHING_WENT_WRONG
        raise "Something went wrong!" # internal error, html changed maybe
      end
      true
    end

    def find(attrs = {})
      alerts.select{|a| attrs.keys.inject(true) {|memo,k| memo = memo && attrs[k] == a.send(k) }}
    end

    def read(url)
      @agent.get(url).body rescue raise "An error occurred while feed reading!"
    end

    # Metaprogramming for find_by commands
    variables = Galerts::Alert.new("").instance_variables.map {|m| m.to_s.delete('@')}
    variables.each do |variable|
      define_method("find_by_#{variable}") do |argument|
        # gsub maybe bad solution for phrases but ... ¯\_(ツ)_/¯
        find({variable.to_sym => argument.gsub("\\","")})
      end
    end
  end
end
