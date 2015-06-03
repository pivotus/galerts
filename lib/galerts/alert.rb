module Galerts
  class Alert
    attr_accessor :query, :id, :data_id, :data_id_2, :domain, :frequency, :sources, :language, :how_many, :region, :delivery, :feed_url
    def initialize(query, options = {})

      default_options = {
        id: 0,
        data_id: 0,
        data_id_2: 0,
        domain: DOMAIN,
        frequency: RT,
        sources: AUTOMATIC,
        language: LANGUAGE,
        how_many: ALL_RESULTS,
        region: ANYWHERE,
        delivery: RSS,
        feed_url: nil
      }

      default_options.each do |key, value|
        options[key] ||= value
      end

      # check options type
      raise "Unknown alert how many" unless HOW_MANY_TYPES.has_key?(options[:how_many])
      raise "Unknown alert delivery type" unless DELIVERY_TYPES.has_key?(options[:delivery])
      raise "Unknown alert frequency type" unless FREQ_TYPES.has_key?(options[:frequency])

      if options[:sources].kind_of?(Array)
        options[:sources].collect do |source|
          raise "Unknown alert source in Array" unless SOURCES_TYPES.has_key?(source)
        end
      elsif options[:sources].nil?
        raise "Nil alert source"
      elsif !SOURCES_TYPES.has_key?(options[:sources])
        raise "Unknown alert source"
      end

      @query = query
      @id = options[:id]
      @data_id = options[:data_id]
      @data_id_2 = options[:data_id_2]
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
