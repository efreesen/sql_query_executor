require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class In < SqlQueryExecutor::Operators::Base
      def selector
        initialize_attributes
        { @field => { "$in" => @value }}
      end

      def logic(is_hash=false)
        initialize_attributes(true)

        "[#{@value.join(', ')}].include?(#{field(is_hash)})"
      end

    private
      def get_value(logic=false)
        value = super

        value.gsub(SqlQueryExecutor::Base::STRING_SPACE, '').split(',').map{ |v| convert_value(v, logic) }
      end
    end
  end
end
