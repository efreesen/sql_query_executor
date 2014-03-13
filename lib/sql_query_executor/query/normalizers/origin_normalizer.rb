require 'sql_query_executor'
require 'sql_query_executor/query/normalizers/base_normalizer'

module SqlQueryExecutor
  module Query
    module Normalizers
      class OriginNormalizer < BaseNormalizer
        BINDING_OPERATORS = ['$and', '$or']
        OPERATORS = {
                      "$gt" => '>',
                      "$lt" => '<',
                      "$gte" => '>=',
                      "$lte" => '<=',
                      "$ne" => '!=',
                      "$in" => 'in'
                    }

        def self.execute(query)
          query_array = []

          query.each do |key, value|
            if value.is_a?(Array)
              query_array << hash_with_array_value(key, value)
            else
              query_array << normal_hash(key, value)
            end
          end


          query_array.join(" and ").gsub('!=', '<>')
        end

      private
        def self.hash_with_array_value(key, value)
          if BINDING_OPERATORS.include?(key)
            key = key.gsub('$', '')
            queries = []

            value.each do |hash|
              queries << execute(hash)
            end

            "(#{queries.join(" #{key.to_s} ")})"
          else
            value = value.first.is_a?(Numeric) ? value : value.map{ |v| "'#{v}'" }
            "#{key} in (#{value.join(',')})"
          end
        end

        def self.normal_hash(key, value)
          operator = '='

          if value.is_a?(Hash)
            operator = OPERATORS[value.keys.first] || operator

            value = convert_param(value.values.first)
          end

          value = convert_param(value)
          value.nil? ? "#{key} is null" : "#{key} #{operator} #{value}"
        end
      end
    end
  end
end