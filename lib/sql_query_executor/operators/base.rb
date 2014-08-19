require 'sql_query_executor/base'

module SqlQueryExecutor
  module Operators
    class Base
      def initialize(query)
        @query = query
      end

      def selector
        initialize_attributes
        { @field => @value }
      end

      def logic(is_hash=false)
        initialize_attributes(true)

        "#{field(is_hash)} #{@operator} #{@value || 'nil'}"
      end

    protected
      def field(is_hash)
        is_hash ? "self[:#{@field}]" : "#{@field}"
      end

      def initialize_attributes(logic=false)
        return if @array

        @query      = SqlQueryExecutor::Query::Normalizers::QueryNormalizer.execute(@query).gsub(SqlQueryExecutor::Base::QUERY_SPACE, ' ')
        @array      = @query.split(' ')
        @operator   = convert_operator
        @field      = get_field
        @value      = get_value(logic)
      end

      def get_field
        @array.first
      end

      def get_value(logic=false)
        value = @array.last.gsub(SqlQueryExecutor::Base::STRING_SPACE, ' ')

        convert_value(value, logic)
      end

      def convert_value(value, logic=false)
        value.gsub!(/[\(\)\'\"]/, "")
        return value.to_i if is_a_number?(value)
        return value.to_f if is_a_number?(value, true)
        return eval(value) if ['true', 'false'].include?(value)

        methods = {3 => "convert_date", 7 => "convert_time"}

        array = split(value)

        if methods.keys.include?(array.size)
          value = (send(methods[array.size], array, logic) || (logic ? "'#{value}'" : value))
        elsif logic
          value = "'#{value}'" if value.is_a?(String)
        end

        value
      end

    private
      def is_a_number?(value, float=false)
        if float
          Float(value)
        else
          Integer(value)
        end rescue false
      end

      def convert_operator
        operators_to_convert = {'<>' => '!=', '=' => '=='}

        operator = @array[1]
        
        operators_to_convert[operator] || operator
      end

      def split(value)
        return [] unless value.size >= 10

        array = value.split(/[ :]/)
        array[0] = array.first.split('-')
        array.flatten
      end

      def convert_date(args, logic=false)
        return if args.first.to_i < 1000
        
        if logic
          "Date.new(#{args[0].to_i}, #{args[1].to_i}, #{args[2].to_i})"
        else
          Date.new(args[0].to_i, args[1].to_i, args[2].to_i)
        end
      end

      def convert_time(args, logic=false)
        return if args.first.to_i < 1000
        args[6] = args[6].gsub('00', ':00').gsub("+:", "+")
        
        if logic
          timezone = args.delete(args.last)
          "Time.new(#{args.join(',')},'#{timezone}')"
        else
          Time.new(*args)
        end
      end
    end
  end
end
