require 'sql_query_executor/query/divider'

module SqlQueryExecutor
  module Query
    class Executor
      class << self
        def execute!(query, collection, data=[])
          sub_query, remaining_query = SqlQueryExecutor::Query::Divider.divide(query, collection)

          result = sub_query.execute!(data)

          remaining_query.nil? ? result.sort_by{ |r| r.id } : execute!(remaining_query, collection, result)
        end
      end
    end
  end
end
