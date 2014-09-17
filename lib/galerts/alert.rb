module Galerts
  class Alert
    attr_accessor :search_query, :id, :data_id, :domain, :frequency, :sources, :language, :how_many, :region, :delivery, :feed_url
    def initialize(search_query, options = {})

      default_options = {
        id: 0,
        data_id: 0,
        domain: 'com',
        frequency: 'rt',
        sources: '',
        language: 'tr',
        how_many: 'all_results',
        region: 'TR',
        delivery: 'rss',
        feed_url: nil
      }

      default_options.each do |key, value|
        options[key] ||= value
      end

      @search_query = search_query
      @id = options[:id]
      @data_id = options[:data_id]
      @domain = options[:domain]
      @frequency = options[:frequency]
      @sources = options[:sources]
      @language = options[:language]
      @how_many = options[:how_many]
      @region = options[:region]
      @delivery = options[:delivery]
      @feed_url = options[:feed_url]
    end
  end
end
