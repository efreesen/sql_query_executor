require 'sql_query_executor'
require 'sql_query_executor/query/normalizers/base_normalizer'

module SqlQueryExecutor
  module Query
    class QueryNormalizer < BaseNormalizer
      CONVERT_METHODS = {"String" => "get_query", "Array" => "interpolate_query", "Hash" => "concatenate_hash"}

      def self.execute(query)
        query = clean_query_attribute(query)
        method = CONVERT_METHODS[query.class.name]

        query = sanitize(send(method, query))
      end

      def self.clean_query(query)
        remove_placeholders execute(query)
      end

    private
      def self.remove_placeholders(query)
        query.gsub(Base::QUERY_SPACE, ' ').gsub(Base::STRING_SPACE, ' ').gsub(Base::TEMP_SPACE, ' ')
      end

      def self.clean_query_attribute(query)
        return query unless query.is_a?(Array)

        query = query.flatten

        (query.size == 1 ? query.first : query).gsub('!=', '<>')
      end

      def self.get_query(query)
        query
      end

      # Prepares query by replacing all ? by it's real values in #args
      def self.interpolate_query(args)
        args.flatten!
        return args.first if args.size == 1 && args.first.is_a?(String)

        query = args.first
        param = args.delete_at(1)

        param = convert_param(param)

        args[0] = query.sub("?", param.is_a?(Numeric) ? param : "#{param}")

        interpolate_query(args)
      end

      # Removes all accents and other non default characters
      def self.sanitize(query)
        new_query = replace_on_query(query, /(["|'].*?["|'])/, " ", Base::STRING_SPACE)
        new_query = replace_on_query(new_query, /(\(.*?\))/, " ", Base::QUERY_SPACE)

        remove_spaces(prepare_query(new_query))
      end

      def self.replace_on_query(query, regexp, pattern, replacement)
        new_query = query ? query.dup : query

        params = new_query.scan(regexp).flatten.compact

        params.each do |param|
          new_param = param.dup

          new_param = new_param.gsub(pattern, replacement)

          new_query = new_query.gsub(param, new_param)
        end

        new_query
      end

      def self.prepare_query(query)
        SubQuery::BINDING_OPERATORS.keys.each do |operator|
          query.gsub!(" #{operator} ", "#{Base::TEMP_SPACE}#{operator}#{Base::QUERY_SPACE}")
        end

        query.gsub(" ", Base::QUERY_SPACE).gsub(Base::TEMP_SPACE, " ")
      end

      def self.remove_spaces(query)
        query.gsub!(",#{Base::QUERY_SPACE}", ',')
        query.gsub!(/\[.*?\]/) { |substr| substr.gsub(' ', '') }
        query
      end
    end
  end
end