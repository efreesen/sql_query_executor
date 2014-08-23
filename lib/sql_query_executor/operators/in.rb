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
        values = []
        value = @array.last.gsub(SqlQueryExecutor::Base::STRING_SPACE, ' ')

        value.split(',').each do |val|
          values.push(convert_value(val, logic))
        end

        values
      end
    end
  end
end
