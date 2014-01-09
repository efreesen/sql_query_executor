module SqlQueryExecutor
  module Operators
    class Base
      def initialize(query, collection)
        @query      = query
        @collection = collection
        @array      = query.split(' ')
        @operator   = @query.split(' ')[1]
        @field      = get_field
        @value      = get_value
      end

    protected
      def get_field
        @array.first
      end

      def get_value
        value = @array.last.gsub('$S$', ' ')

        convert_value(value)
      end

      def convert_value(value)
        array = []

        if value.size >= 10
          array = value.split(/ |:/)
          array[0] = array.first.split('-')
          array = array.flatten
        end

        if (value.to_i.to_s == value.to_s)
          return value.to_i
        elsif array.size == 3
          return array.first.to_i > 1000 ? Date.new(array[0].to_i, array[1].to_i, array[2].to_i) : value
        elsif array.size == 7
          array[6] = array[6] == '+0000' ? '+00:00' : array[6].gsub('00', ':00')
          return array.first.to_i > 1000 ? Time.new(*array) : value
        end

        value
      end
    end
  end
end
