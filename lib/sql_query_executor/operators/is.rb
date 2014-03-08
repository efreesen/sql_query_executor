require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class Is < SqlQueryExecutor::Operators::Base
      def initialize(query, collection)
        super
        convert_operator
      end

      def execute!
        @collection.select do |record|
          value = record.send(@field)

          value.send(@operator, @value)
        end
      end

      def selector
        @operator == '==' ? { @field => @value } : { @field => {'$ne' => @value} }
      end

    private
      def get_value
        @array.include?('null') ? nil : convert_value(@array.last)
      end

      def convert_operator
        @operator = @array.include?('not') ? '!=' : '=='
      end
    end
  end
end
