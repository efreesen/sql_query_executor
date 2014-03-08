require 'sql_query_executor/operators/default'
require 'sql_query_executor/operators/between'
require 'sql_query_executor/operators/is'
require 'sql_query_executor/operators/in'

module SqlQueryExecutor
  module Query
    class Sentence
      attr_reader :query

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

      def initialize(query, collection)
        @query    = query
        @collection = collection
        @array = query.split(' ')

        set_operator
      end

      # The data parameter is only declared for SubQuery compatibility purposes
      def execute!(data=[])
        return [] unless @operator

        @operator.execute!
      end

      def selector
        @operator.selector
      end

    private
      def set_operator
        operator = OPERATORS[@query.split(' ')[1]]

        @operator = operator ? operator.new(@query, @collection) : nil
      end
    end
  end
end
