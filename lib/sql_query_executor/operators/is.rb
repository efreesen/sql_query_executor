require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class Is < SqlQueryExecutor::Operators::Base
      def selector
        initialize_attributes

        @operator == '==' ? { @field => @value } : { @field => {'$ne' => @value} }
      end

    private
      def initialize_attributes(logic=false)
        super
        convert_operator
      end

      def get_value(logic=false)
        @array.include?('null') ? nil : convert_value(@array.last, logic)
      end

      def convert_operator
        @operator = @array.include?('not') ? '!=' : '=='
      end
    end
  end
end
