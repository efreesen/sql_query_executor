require 'sql_query_executor/query/sentence'

module SqlQueryExecutor
  module Query
    class SubQuery
      BINDING_OPERATORS = { "or" => "+", "and" => "&" }
      attr_reader :children, :kind, :binding_operator
      ADD_CHILDREN_METHODS = { sentence: :add_sentence_children, sub_query: :add_sub_query_children }

      def initialize(query)
        @children = []
        @query    = query
        initialize_attributes
      end

      def execute!(collection, data=[])
        is_hash = collection.first.is_a?(Hash)
        method_eval = logic(is_hash)
        klass = collection.first.class

        klass.instance_eval do
          eval("define_method(:this_method_will_be_removed_in_a_little_while) { #{method_eval} }")
        end

        result = collection.select{ |object| object.this_method_will_be_removed_in_a_little_while }

        klass.class_eval { undef :this_method_will_be_removed_in_a_little_while }

        is_hash ? result.sort_by{ |hash| hash[:id] } : result.sort_by(&:id)
      end

      def selector
        hash = {}

        @children.each do |child|
          if child.respond_to?(:binding_operator) && child.binding_operator
            operator = BINDING_OPERATORS.invert[child.binding_operator]
            hash = {"$#{operator}" => [hash,child.selector]}
          else
            hash.merge!(child.selector)
          end
        end

        hash
      end

      def to_sql
        SqlQueryExecutor::Query::Normalizers::QueryNormalizer.clean_query(@query)
      end

      def logic(is_hash=false)
        string = ''

        @children.each do |child|
          if child.respond_to?(:binding_operator) && child.binding_operator
            operator = BINDING_OPERATORS.invert[child.binding_operator]
            string = "(#{string} #{operator} #{child.logic(is_hash)})"
          else
            string += child.logic(is_hash)
          end
        end

        string
      end

    private
      def initialize_attributes
        return if @kind

        set_binding_operator
        set_kind
        set_children
      end

      def set_binding_operator
        @binding_operator = nil
        operator = @query.split(Base::QUERY_SPACE).first

        if ["and", "or"].include?(operator)
          @binding_operator =  BINDING_OPERATORS[operator]
          @query = @query.gsub("#{operator}$QS$", "")
        end
      end

      def set_kind
        @kind = is_single_query? ? :sentence : :sub_query
      end

      def set_children
        send(ADD_CHILDREN_METHODS[@kind])
      end

      def add_sentence_children
        @children << SqlQueryExecutor::Query::Sentence.new(@query.gsub(Base::QUERY_SPACE, " "))
      end

      def add_sub_query_children
        array = @query.split(" ")
        queries = []

        array.each do |query|
          sanitized_query = replace_parentheses(query)
          params = sanitized_query.scan(/\$op1\$(\S+)\$cp1\$/).flatten.compact

          params.each do |param|
            string = param.gsub("$QS$and$QS$", " and$QS$").gsub("$QS$or$QS$", " or$QS$")
            query = sanitized_query.gsub(param, string)
          end

          query = query.gsub("\$op1\$", "").gsub("\$cp1\$", "").gsub(/\$\Sp\d\$/, "")

          @children << SqlQueryExecutor::Query::SubQuery.new(query)
        end
      end

      def is_single_query?
        array = @query.gsub(Base::QUERY_SPACE, ' ').split(' ')

        array.size <= 5
      end

      def replace_parentheses(query)
        count = 1
        string = ""

        query.each_char do |c|
          char = c
          
          if c == "("
            char = "$op#{count}$"
            count += 1
          end

          if c == ")"
            count -= 1
            char = "$cp#{count}$"
          end

          string << char
        end

        string
      end
    end
  end
end
