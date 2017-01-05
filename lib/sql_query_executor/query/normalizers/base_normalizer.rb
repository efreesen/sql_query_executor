require 'sql_query_executor'

module SqlQueryExecutor
  module Query
    module Normalizers
      class BaseNormalizer
      private
        # Returns converted #param based on its Class, so it can be used on the query
        def self.convert_param(param)
          case param.class.name
          when "NilClass"
            nil
          when "String"
            # Exit early if we have an empty string, otherwise a single ' will be returned
            return "''" if(param == "")
            "'#{param}'".gsub("''", "'").gsub('""', '"')
          when "Date"
            "'#{param.strftime("%Y-%m-%d")}'"
          when "Time"
            "'#{param.strftime("%Y-%m-%d %H:%M:%S %z")}'"
          else
            param.to_s
          end
        end

        def self.attributes_from_query(selector)
          return {} if selector.empty?

          attributes = {}

          selector.each do |key, value|
            case value.class.name
            when 'Array'
              attributes.merge!(attributes_from_array(value)) if key == '$and'
            when 'Hash'
              attributes.merge!(attributes_from_query(value))
            else
              attributes[key.to_sym] = value unless key.to_s.include?('$')
            end
          end

          attributes
        end

      protected
        def self.attributes_from_array(array)
          attributes = {}

          array.each do |hash|
            attributes.merge!(attributes_from_query(hash))
          end

          attributes
        end
      end
    end
  end
end