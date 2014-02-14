module SqlQueryExecutor
  module Query
    class Base
      attr_reader :query

      CONVERT_METHODS = {"String" => ["get_query", ""], "Array" => ["interpolate_query", "query.flatten"], "Hash" => ["concatenate_hash", "query"]}
      STRING_SPACE = "$SS$"
      QUERY_SPACE  = "$QS$"
      TEMP_SPACE  = "$TS$"

      def initialize(query, collection)
        query = clean_query_attribute(query)
        array = CONVERT_METHODS[query.class.name]

        query = sanitize(send(array.first, query))
        @query = SqlQueryExecutor::Query::SubQuery.new query, collection
      end

      def execute!
        @query.execute!
      end

    private
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
        cruft = /\'|\"|\(|\)/

        new_query = query ? query.dup : query
        params = new_query.scan(/(["|'].*?["|'])/).flatten.compact

        params.each do |param|
          new_param = param.dup

          new_param = new_param.gsub(" ", STRING_SPACE)

          new_query = new_query.gsub(param, new_param)
        end

        
        params = new_query.scan(/(\(.*?\))/).flatten.compact

        params.each do |param|
          new_param = param.dup

          new_param = new_param.gsub(" ", QUERY_SPACE)

          new_query = new_query.gsub(param, new_param)
        end

        query = new_query.gsub(" and ", "#{TEMP_SPACE}and#{QUERY_SPACE}").gsub(" or ", "#{TEMP_SPACE}or#{QUERY_SPACE}").gsub(" ", QUERY_SPACE).gsub(TEMP_SPACE, " ")

        remove_spaces(query)
      end

      def remove_spaces(query)
        query.gsub!(/\[.*?\]/) { |substr| substr.gsub(' ', '') }
        query
      end

      # Returns converted #param based on its Class, so it can be used on the query
      def convert_param(param)
        case param.class.name
        when "String"
          param = "'#{param}'"
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

        query.each do |key, value|
          if value.is_a?(Array)
            value = value.first.is_a?(Numeric) ? value : value.map{ |v| "'#{v}'" }
            query_array << "#{key} in (#{value.join(',')})"
          else
            value = value.is_a?(Numeric) ? value : "'#{value}'"
            query_array << "#{key} = #{value}"
          end
        end

        query_array.join(" and ")
      end
    end
  end
end