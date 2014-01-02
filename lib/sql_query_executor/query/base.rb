require 'sql_query_executor/query/executor'

module SqlQueryExecutor
  module Query
    class Base
      def initialize(query, collection)
        @query      = interpolate_query(query)
        @collection = collection
        sanitize
      end

      def execute!
        SqlQueryExecutor::Query::Executor.execute!(@query, @collection)
      end

    private
      # Prepares query by replacing all ? by it's real values in #args
      def interpolate_query(args)
        return args.first if args.size == 1

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
    end
  end
end