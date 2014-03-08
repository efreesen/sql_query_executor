require 'ostruct'
require 'sql_query_executor/query/query_normalizer'
require 'sql_query_executor/query/sub_query'

# Simulates a SQL where clause to filter objects from the database
module SqlQueryExecutor #:nodoc:
  class Base #:nodoc:
    STRING_SPACE    = "$SS$"
    QUERY_SPACE     = "$QS$"
    TEMP_SPACE      = "$TS$"

    def initialize(collection, query)
      query = query.first if query.respond_to?(:size) && query.size == 1 && !query.is_a?(Hash)

      message = check_query(query)
      raise ArgumentError.new(message) if message

      get_collection(collection)
      query = Query::QueryNormalizer.execute(query)
      @query = SqlQueryExecutor::Query::SubQuery.new query, @collection
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

    # Recursive method that divides the query in sub queries, executes each part individually
    # and finally relates its results as specified in the query.
    def self.where(collection, *query)
      self.new(collection, query).execute!
    end

  private
    def get_collection(collection)
      if collection.any? && collection.first.is_a?(Hash)
        convert_collection(collection)
      else
        @collection = conforming_collection?(collection) ? collection : []
      end
    end

    def convert_collection(collection)
      @collection = []
      collection.each do |object|
        attributes = object.is_a?(Hash) ? object : object.attributes
        register = OpenStruct.new(attributes)
        @collection << register
      end
    end

    def conforming_collection?(collection)
      collection.first.respond_to?(:attributes)
    end

    def check_query(query)
      return "must pass at least one argument" if query.empty?

      if query.is_a?(Array) && !query.first.is_a?(String)
        "First element from array must be a String. eg: [\"name = ?\", \"John\"]"
      end
    end
  end
end