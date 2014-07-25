require 'sql_query_executor/base'

module SqlQueryExecutor
  module Operators
    class Base
      def initialize(query)
        @query = query
      end

      def selector
        initialize_attributes
        { @field => @value }
      end

    protected
      def initialize_attributes
        return if @array

        @query      = SqlQueryExecutor::Query::Normalizers::QueryNormalizer.execute(@query).gsub(SqlQueryExecutor::Base::QUERY_SPACE, ' ')
        @array      = @query.split(' ')
        @operator   = @query.split(' ')[1]
        @field      = get_field
        @value      = get_value
      end

      def get_field
        @array.first
      end

      def get_value
        value = @array.last.gsub(SqlQueryExecutor::Base::STRING_SPACE, ' ')

        convert_value(value)
      end

      def convert_value(value)
        value.gsub!(/[\(\)\'\"]/, "")
        return value.to_i if is_a_number?(value)
        return eval(value) if ['true', 'false'].include?(value)

        methods = {3 => "convert_date", 7 => "convert_time"}

        array = split(value)

        value = (send(methods[array.size], array) || value) if methods.keys.include?(array.size)

        value
      end

    private
      def is_a_number?(value)
        value.to_s == value.to_i.to_s
      end

      def split(value)
        return [] unless value.size >= 10

        array = value.split(/[ :]/)
        array[0] = array.first.split('-')
        array.flatten
      end

      def convert_date(args)
        return if args.first.to_i < 1000
        
        Date.new(args[0].to_i, args[1].to_i, args[2].to_i)
      end

      def convert_time(args)
        return if args.first.to_i < 1000
        args[6] = args[6].gsub('00', ':00').gsub("+:", "+")
        
        Time.new(*args)
      end
    end
  end
end
