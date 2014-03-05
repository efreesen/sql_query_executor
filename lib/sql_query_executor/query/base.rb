require 'sql_query_executor/query/query_normalizer'

module SqlQueryExecutor
  module Query
    class Base
      STRING_SPACE    = "$SS$"
      QUERY_SPACE     = "$QS$"
      TEMP_SPACE      = "$TS$"

      def initialize(query, collection)
        query = QueryNormalizer.execute(query)
        @query = SqlQueryExecutor::Query::SubQuery.new query, collection
      end

      def execute!
        @query.execute!
      end

      def to_sql
        @query.to_sql
      end

      def selector
        @query.selector
      end
    end
  end
end