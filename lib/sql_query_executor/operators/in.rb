require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class In < SqlQueryExecutor::Operators::Base
      def execute!
        result = @collection.select do |record|
          value = record.send(@field)

          @value.send('include?', value)
        end
      end

      def selector
        { @field => { "$in" => @value }}
      end

    private
      def get_value
        value = super

        value.gsub(SqlQueryExecutor::Base::STRING_SPACE, '').split(',').map{ |v| convert_value(v) }
      end
    end
  end
end
