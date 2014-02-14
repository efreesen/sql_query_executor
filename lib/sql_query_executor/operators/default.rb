require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class Default < SqlQueryExecutor::Operators::Base
      def initialize(query, collection)
        super
        convert_operator
      end

      def execute!(result)
        @collection.select do |record|
          value = record.send(@field.to_s)

          value.send(@operator, @value) rescue false
        end
      end

    private
      def convert_operator
        @operator = @operator == "="  ? "==" : @operator
        @operator = @operator == "<>" ? "!=" : @operator
      end
    end
  end
end
