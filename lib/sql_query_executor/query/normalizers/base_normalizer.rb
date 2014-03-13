require 'sql_query_executor'

module SqlQueryExecutor
  module Query
    class BaseNormalizer
    private
      # Returns converted #param based on its Class, so it can be used on the query
      def self.convert_param(param)
        case param.class.name
        when "NilClass"
          nil
        when "String"
          "'#{param}'".gsub("''", "'").gsub('""', '"')
        when "Date"
          "'#{param.strftime("%Y-%m-%d")}'"
        when "Time"
          "'#{param.strftime("%Y-%m-%d %H:%M:%S %z")}'"
        else
          param.to_s
        end
      end
    end
  end
end