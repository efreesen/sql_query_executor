require 'sql_query_executor/query/executor'

module SqlQueryExecutor
  module Query
    class Base
      attr_reader :query

      CONVERT_METHODS = {"String" => ["get_query", ""], "Array" => ["interpolate_query", "query.flatten"], "Hash" => ["concatenate_hash", "query"]}

      def initialize(query, collection)
        query = clean_query_attribute(query)
        array = CONVERT_METHODS[query.class.name]

        @query      = send(array.first, query)
        @collection = collection
        sanitize
      end

      def execute!
        SqlQueryExecutor::Query::Executor.execute!(@query, @collection)
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

        args[0] = query.sub("?", param)

        interpolate_query(args)
      end

      # Removes all accents and other non default characters
      def sanitize
        cruft = /\'|\"|\(|\)/

        new_query = @query ? @query.dup : @query
        params = new_query.scan(/(["|'].*?["|'])|(\(.*?\))/).flatten.compact

        params.each do |param|
          new_param = param.dup

          new_param = new_param.gsub(cruft,"")
          new_param = new_param.gsub(" ", "$S$")

          new_query = new_query.gsub(param, new_param)
        end

        @query = new_query

        remove_spaces
      end

      def remove_spaces
        @query.gsub!(/\[.*?\]/) { |substr| substr.gsub(' ', '') }
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
            query_array << "#{key} in (#{value.join(',')})"
          else
            query_array << "#{key} = #{value}"
          end
        end

        query_array.join(" and ")
      end
    end
  end
end