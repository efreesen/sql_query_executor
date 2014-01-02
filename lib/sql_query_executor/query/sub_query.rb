require 'sql_query_executor/operators/default'
require 'sql_query_executor/operators/between'
require 'sql_query_executor/operators/is'
require 'sql_query_executor/operators/in'

module SqlQueryExecutor
  module Query
    class SubQuery
      OPERATORS = {
        "between" => SqlQueryExecutor::Operators::Between,
        "is"      => SqlQueryExecutor::Operators::Is,
        "in"      => SqlQueryExecutor::Operators::In,
        "="       => SqlQueryExecutor::Operators::Default,
        ">"       => SqlQueryExecutor::Operators::Default,
        "<"       => SqlQueryExecutor::Operators::Default,
        ">="      => SqlQueryExecutor::Operators::Default,
        "<="      => SqlQueryExecutor::Operators::Default,
        "<>"      => SqlQueryExecutor::Operators::Default,
        "!="      => SqlQueryExecutor::Operators::Default,
        "not"     => SqlQueryExecutor::Operators::Default,
        "exists"  => SqlQueryExecutor::Operators::Default,#Exists
      }

      BINDING_OPERATORS = {
        "and" => "&",
        "or"  => "+"
      }

      def initialize(query, collection)
        @query    = query
        @collection = collection
        @array = query.split(' ')

        set_binding_operator
        set_operator
      end

      def execute!(data)
        return [] unless @operator

        result = @operator.execute!

        result = data.send(@binding_operator, result) if @binding_operator && (data && !data.empty?)

        result
      end

    private
      def set_operator
        operator = OPERATORS[@query.split(' ')[1]]

        @operator = operator ? operator.new(@query, @collection) : nil
      end

      def set_binding_operator
        @binding_operator = BINDING_OPERATORS[@array.first]

        fix_query if @binding_operator
      end

      def fix_query
        @array.delete_at(0) 

        @query = @array.join(' ')
      end
    end
  end
end
