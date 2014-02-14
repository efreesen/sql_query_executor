require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Query::Base do
  let(:single_query) { "name$QS$=$QS$'US'" }
  let(:double_query) { "name$QS$=$QS$'US' and$QS$language$QS$=$QS$'English'" }
  let(:data) { [] }

  context "query is a string" do
    it 'keeps the same string' do
      query_executor = SqlQueryExecutor::Query::Base.new("name = 'US'", data)
      expect(query_executor.query.query).to eq single_query
    end

    context "query has parentheses to define priority" do
      it "respects priority" do
        query = "(monarch = 'The Crown of England' and name = 'US') or (language is null)"
        escaped_query = "(monarch$QS$=$QS$'The$SS$Crown$SS$of$SS$England'$QS$and$QS$name$QS$=$QS$'US') or$QS$(language$QS$is$QS$null)"

        query_executor = SqlQueryExecutor::Query::Base.new(query, data)
        expect(query_executor.query.query).to eq escaped_query
      end
    end
  end

  context "query is an array" do
    let!(:query) { ["name = ?", "US"] }
    it 'interpolates the array into a string' do
      query_executor = SqlQueryExecutor::Query::Base.new(query, data)
      expect(query_executor.query.query).to eq single_query
    end

    it 'interpolates the double array into a string' do
      new_query = ["name = ? and language = ?", "US", 'English']

      query_executor = SqlQueryExecutor::Query::Base.new(new_query, data)
      expect(query_executor.query.query).to eq double_query
    end
  end

  context "query is a hash" do
    let(:query) { { name: "US" } }

    it 'convets hash into a query' do
      query_executor = SqlQueryExecutor::Query::Base.new(query, data)
      expect(query_executor.query.query).to eq single_query
    end

    it 'convets double hash into a query' do
      query[:language] = 'English'

      query_executor = SqlQueryExecutor::Query::Base.new(query, data)
      expect(query_executor.query.query).to eq double_query
    end

    context 'value is an Array' do
      let(:query) { { name: ["US", "Canada"] } }

      it 'creates an in condition' do
        query_executor = SqlQueryExecutor::Query::Base.new(query, data)

        expect(query_executor.query.query).to eq "name$QS$in$QS$('US','Canada')"
      end
    end
  end
end