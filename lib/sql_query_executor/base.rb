require 'ostruct'
require 'sql_query_executor/query/base'
require 'sql_query_executor/query/sub_query'

# Simulates a SQL where clause to filter objects from the database
module SqlQueryExecutor #:nodoc:
  class Base #:nodoc:
    def initialize(collection=[])
      @collection = []

      if collection.any? && collection.first.is_a?(Hash)
        convert_collection(collection)
      else
        @collection = conforming_collection?(collection) ? collection : []
      end
    end

    # Recursive method that divides the query in sub queries, executes each part individually
    # and finally relates its results as specified in the query.
    def where(*query)
      raise ArgumentError.new("must pass at least one argument") if query.empty?
      query = query.first if query.respond_to?(:size) && query.size == 1

      message = check_query(query)
      raise ArgumentError.new(message) if message

      query = SqlQueryExecutor::Query::Base.new(query, @collection)
      query.execute!
    end

  private
    def convert_collection(collection)
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
      if query.is_a?(Array) && !query.first.is_a?(String)
        "First element from array must be a String. eg: [\"name = ?\", \"John\"]"
      end
    end
  end
end