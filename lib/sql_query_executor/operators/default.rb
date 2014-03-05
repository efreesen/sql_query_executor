require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class Default < SqlQueryExecutor::Operators::Base
      SELECTORS = {
        "=="      => nil,
        ">"       => "$gt",
        "<"       => "$lt",
        ">="      => "$gte",
        "<="      => "$lte",
        "!="      => "$ne"
      }

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

      def selector
        operator = SELECTORS[@operator]

        { @field.to_sym => operator ? {operator => @value} : @value}
      end

    private
      def convert_operator
        @operator = @operator == "="  ? "==" : @operator
        @operator = @operator == "<>" ? "!=" : @operator
      end
    end
  end
end
