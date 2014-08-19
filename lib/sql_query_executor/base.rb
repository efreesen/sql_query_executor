require 'ostruct'
require 'sql_query_executor/query/normalizers/query_normalizer'
require 'sql_query_executor/query/sub_query'

# Simulates a SQL where clause to filter objects from the database
module SqlQueryExecutor #:nodoc:
  class Base #:nodoc:
    STRING_SPACE    = "$SS$"
    QUERY_SPACE     = "$QS$"
    TEMP_SPACE      = "$TS$"

    def initialize(query)
      if query.respond_to?(:size) && query.size == 1 && !query.is_a?(Hash)
        @query = query.first
      else
        @query = query
      end

      message = check_query
      raise ArgumentError.new(message) if message
    end

    def execute!(collection)
      set_collection(collection)

      convert_query.execute!(@collection)
    end

    def to_sql
      return @to_sql if @to_sql

      @to_sql = @query
      
      return @query if @query.is_a?(String)

      @to_sql = convert_query.to_sql
    end

    def selector
      return @selector if @selector

      @selector = @query
      
      return @query if @query.is_a?(Hash)

      @selector = convert_query.selector
    end

    # Recursive method that divides the query in sub queries, executes each part individually
    # and finally relates its results as specified in the query.
    def self.where(collection, *query)
      self.new(query).execute!(collection)
    end

  private
    def convert_query
      return @convert_query if @convert_query

      query = Query::Normalizers::QueryNormalizer.execute(@query)
      
      @convert_query = SqlQueryExecutor::Query::SubQuery.new(query)
    end

    def set_collection(collection)
      return if @collection

      @collection = collection
    end

    def convert_collection(collection=[])
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

    def check_query
      if @query.is_a?(Array) && !@query.first.is_a?(String)
        "First element from array must be a String. eg: [\"name = ?\", \"John\"]"
      end
    end
  end
end