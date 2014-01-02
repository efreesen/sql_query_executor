require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class In < SqlQueryExecutor::Operators::Base
      def execute!
        @collection.select do |record|
          value = record.send(@field)

          @value.send('include?', value)
        end
      end

    private
      def get_value
        value = super

        value.gsub('$S$', '').split(',').map &:strip
      end
    end
  end
end
