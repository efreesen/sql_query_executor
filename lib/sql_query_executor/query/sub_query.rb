module SqlQueryExecutor
  module Query
    class SubQuery
      BINDING_OPERATORS = { "or" => "+", "and" => "&" }
      attr_reader :query, :children, :kind
      ADD_CHILDREN_METHODS = { sentence: :add_sentence_children, sub_query: :add_sub_query_children }
      def initialize(query, collection)
        @collection = collection
        @query      = query
        @children   = []
        set_binding_operator
        set_kind
        set_children
      end

      def execute!(data=[])
        return [] unless @children

        result = []

        @children.each do |child|
          result = child.execute!(result)
        end

        result = data.send(@binding_operator, result) if @binding_operator && (data && !data.empty?)

        result.sort_by(&:id)
      end

    private
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
        @children << SqlQueryExecutor::Query::Sentence.new(@query.gsub(Base::QUERY_SPACE, " "), @collection)
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

          @children << SqlQueryExecutor::Query::SubQuery.new(query, @collection)
        end
      end

      def is_single_query?
        array = @query.gsub(Base::QUERY_SPACE, ' ').split(' ')

        array.size <= 5
      end

      def build_sub_query(query)
        array = query.split(" ")

        offset = is_binding_operator?(array.first) ? 1 : 0
        operator = array[1+offset]

        result = case operator
        when "between"
          array[0..4+offset]
        when "is"
          size = array[2+offset] == "not" ? 3 : 2
          array[0..size+offset]
        when "not"
          array[0..3+offset]
        else
          array[0..2+offset]
        end

        result.join(' ')
      end

      def is_binding_operator?(operator)
        BINDING_OPERATORS.include?(operator)
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
