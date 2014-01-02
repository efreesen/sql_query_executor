require 'ostruct'
require 'sql_query_executor/query/base'

# Simulates a SQL where clause to filter objects from the database
module SqlQueryExecutor #:nodoc:
  class Base #:nodoc:
    def initialize(collection=[])
      @collection = []

      collection.each do |object|
        register = OpenStruct.new(object)
        @collection << register
      end
    end

    # Recursive method that divides the query in sub queries, executes each part individually
    # and finally relates its results as specified in the query.
    def where(*query)
      query = SqlQueryExecutor::Query::Base.new(query, @collection)
      query.execute!
    end
  end
end