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

      def selector
        initialize_attributes

        operator = SELECTORS[@operator]

        { @field => operator ? {operator => @value} : @value}
      end

    private
    end
  end
end
