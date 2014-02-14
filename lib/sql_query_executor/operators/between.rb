require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class Between < SqlQueryExecutor::Operators::Base
      def execute!(result)
        @collection.select do |record|
          value = convert_value(record.send(@field).to_s)

          if value.class != @value.first.class
            false
          else
            greather_than = value.send('>=', @value.first)
            smaller_than  = value.send('<=', @value.last)

            greather_than && smaller_than
          end
        end
      end

    private
      def get_value
        value = []

        value << convert_value(@array[2].gsub(SqlQueryExecutor::Query::Base::STRING_SPACE, ' '))
        value << convert_value(@array[4].gsub(SqlQueryExecutor::Query::Base::STRING_SPACE, ' '))
      end
    end
  end
end
