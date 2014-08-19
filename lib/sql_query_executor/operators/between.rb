require 'sql_query_executor/operators/base'

module SqlQueryExecutor
  module Operators
    class Between < SqlQueryExecutor::Operators::Base
      def selector
        initialize_attributes
        { @field => { "$gte" => @value.first, "$lte" => @value.last }}
      end

      def logic(is_hash=false)
        initialize_attributes(true)

        "#{field(is_hash)} >= #{@value[0]} && #{field(is_hash)} <= #{@value[1]}"
      end

    private
      def get_value(logic=false)
        value = []

        value << convert_value(@array[2].gsub(SqlQueryExecutor::Base::STRING_SPACE, ' '), logic)
        value << convert_value(@array[4].gsub(SqlQueryExecutor::Base::STRING_SPACE, ' '), logic)
      end
    end
  end
end
