module LinkedIn

  module Search
    def search(options={}, type='people')

      path = "/#{type.to_s}-search"

      if options.is_a?(Hash)
        fields = options.delete(:fields)
        path += field_selector(fields) if fields

        facet = options.delete(:facet)
        facet_string = facet.collect { |f| "facet=#{f}"}.join('&')
      end

      options = { :keywords => options } if options.is_a?(String)
      options = format_options_for_query(options)

      formatted_uri = to_uri(path, options)

      if facet_string
        if formatted_uri.match(/\?/)
          formatted_uri += "&" + facet_string
        else
          formatted_uri += facet_string
        end
      end

      result_json = get(formatted_uri)

      Mash.from_json(result_json)
    end

    private

      def format_options_for_query(opts)
        opts.inject({}) do |list, kv|
          key, value = kv.first.to_s.gsub("_","-"), kv.last
          list[key]  = sanitize_value(value)
          list
        end
      end

      def sanitize_value(value)
        value = value.join("+") if value.is_a?(Array)
        value = value.gsub(" ", "+") if value.is_a?(String)
        value
      end

      def field_selector(fields)
        result = ":("
        fields = fields.to_a.map do |field|
          if field.is_a?(Hash)
            innerFields = []
            field.each do |key, value|
              innerFields << key.to_s.gsub("_","-") + field_selector(value)
            end
            innerFields.join(',')
          else
            field.to_s.gsub("_","-")
          end
        end
        result += fields.join(',')
        result += ")"
        result
      end
  end

end
