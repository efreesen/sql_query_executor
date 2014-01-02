require 'sql_query_executor/query/sub_query'

module SqlQueryExecutor
  module Query
    class Divider
      BINDING_OPERATORS = ['and', 'or']

      class << self
        def divide(query, collection)
          @query = query
          divide_query(collection)
        end

      private
        # Splits the first sub query from the rest of the query and returns it.
        def divide_query(collection)
          array = @query.split(" ")
          operator = array[1].downcase

          sub_query = get_sub_array(operator, array)
          remaining_query = @query.gsub(sub_query, '').strip

          sub_query = SqlQueryExecutor::Query::SubQuery.new(sub_query, collection)

          return sub_query, remaining_query == '' ? nil : remaining_query
        end

        def get_sub_array(operator, array)
          result = case operator
          when "between"
            array[0..4]
          when "is"
            size = array[2] == "not" ? 3 : 2
            array[0..size]
          when "not"
            array[0..3]
          else
            array[0..2]
          end

          result = fix_array(array, result)

          result.join(' ')
        end

        def fix_array(array, result)
          if BINDING_OPERATORS.include?(result.first)
            array[0..result.size]
          else
            result
          end
        end
      end
    end
  end
end