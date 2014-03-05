require 'sql_query_executor'

module SqlQueryExecutor
  module Query
    class QueryNormalizer
      class << self
        CONVERT_METHODS = {"String" => ["get_query", ""], "Array" => ["interpolate_query", "query.flatten"], "Hash" => ["concatenate_hash", "query"]}

        def execute(query)
          query = clean_query_attribute(query)
          array = CONVERT_METHODS[query.class.name]

          query = sanitize(send(array.first, query))
        end

        def clean_query(query)
          query = execute(query)

          remove_placeholders(query)
        end

      private
        def remove_placeholders(query)
          query.gsub(Base::QUERY_SPACE, ' ').gsub(Base::STRING_SPACE, ' ').gsub(Base::TEMP_SPACE, ' ')
        end

        def clean_query_attribute(query)
          return query unless query.is_a?(Array)

          query = query.flatten

          query.size == 1 ? query.first : query
        end

        def get_query(query)
          query
        end

        # Prepares query by replacing all ? by it's real values in #args
        def interpolate_query(args)
          args.flatten!
          return args.first if args.size == 1 && args.first.is_a?(String)

          query = args.first
          param = args.delete_at(1)

          param = convert_param(param)

          args[0] = query.sub("?", param.is_a?(Numeric) ? param : "#{param}")

          interpolate_query(args)
        end

        # Removes all accents and other non default characters
        def sanitize(query)
          new_query = replace_on_query(query, /(["|'].*?["|'])/, " ", Base::STRING_SPACE)
          new_query = replace_on_query(new_query, /(\(.*?\))/, " ", Base::QUERY_SPACE)

          remove_spaces(prepare_query(new_query))
        end

        def replace_on_query(query, regexp, pattern, replacement)
          new_query = query ? query.dup : query

          params = new_query.scan(regexp).flatten.compact

          params.each do |param|
            new_param = param.dup

            new_param = new_param.gsub(pattern, replacement)

            new_query = new_query.gsub(param, new_param)
          end

          new_query
        end

        def prepare_query(query)
          SubQuery::BINDING_OPERATORS.keys.each do |operator|
            query.gsub!(" #{operator} ", "#{Base::TEMP_SPACE}#{operator}#{Base::QUERY_SPACE}")
          end

          query.gsub(" ", Base::QUERY_SPACE).gsub(Base::TEMP_SPACE, " ")
        end

        def remove_spaces(query)
          query.gsub!(/\[.*?\]/) { |substr| substr.gsub(' ', '') }
          query
        end

        # Returns converted #param based on its Class, so it can be used on the query
        def convert_param(param)
          case param.class.name
          when "String"
            param = "'#{param}'".gsub("''", "'").gsub('""', '"')
          when "Date"
            param = "'#{param.strftime("%Y-%m-%d")}'"
          when "Time"
            param = "'#{param.strftime("%Y-%m-%d %H:%M:%S %z")}'"
          else
            param = param.to_s
          end
        end

        def concatenate_hash(query)
          return "" unless query.is_a?(Hash)
          query_array = []
          operators   = {"$gt" => '>', "$lt" => '<', "$gte" => '>=', "$lte" => '<=', "$ne" => '!=', "$in" => 'in'}

          query.each do |key, value|
            if value.is_a?(Array)
              if [:and, :or].include?(key)
                queries = []

                value.each do |hash|
                  queries << concatenate_hash(hash)
                end

                query_array << queries.join(" #{key.to_s} ")
              else
                value = value.first.is_a?(Numeric) ? value : value.map{ |v| "'#{v}'" }
                query_array << "#{key} in (#{value.join(',')})"
              end
            else
              operator = '='

              if value.is_a?(Hash)
                operator = operators[value.keys.first] || operator

                value = convert_param(value.values.first) if operators.include?(value.keys.first)
              end

              value = value.is_a?(Numeric) ? value : "#{convert_param(value)}"
              query_array << "#{key} #{operator} #{value}"
            end
          end

          query_array.join(" and ")
        end
      end
    end
  end
end