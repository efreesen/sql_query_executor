require 'spec_helper'

require 'sql_query_executor'
require 'pry'

describe SqlQueryExecutor::Query::Base do
  let(:single_query) { "name = 'US'" }
  let(:double_query) { "name = 'US' and language = 'English'" }
  let(:single_selector) { {:name => 'US'} }
  let(:double_selector) { {:and => [{:name => 'US'}, {:language => 'English'}]} }
  let(:data) { [] }

  context "SQL queries" do

    context "query is a string" do
      it 'keeps the same string' do
        query_executor = SqlQueryExecutor::Query::Base.new("name = 'US'", data)
        expect(query_executor.to_sql).to eq single_query
      end

      context "query has parentheses to define priority" do
        it "respects priority in sql" do
          query = "(monarch = 'The Crown of England' and name = 'US') or (language is null)"
          escaped_query = "(monarch = 'The Crown of England' and name = 'US') or (language is null)"

          query_executor = SqlQueryExecutor::Query::Base.new(query, data)
          expect(query_executor.to_sql).to eq escaped_query
        end

        it "respects priority in selector" do
          query = "(monarch = 'The Crown of England' and name = 'US') or (language is null)"
          selector = {:or=>[{:and=>[{:monarch=>"The Crown of England"}, {:name=>"US"}]}, {"language"=>"nil"}]}

          query_executor = SqlQueryExecutor::Query::Base.new(query, data)
          expect(query_executor.selector).to eq selector
        end
      end
    end

    context "query is an array" do
      let!(:query) { ["name = ?", "US"] }
      it 'interpolates the array into a string' do
        query_executor = SqlQueryExecutor::Query::Base.new(query, data)
        expect(query_executor.to_sql).to eq single_query
      end

      it 'interpolates the array into a selector' do
        query_executor = SqlQueryExecutor::Query::Base.new(query, data)
        expect(query_executor.selector).to eq single_selector
      end

      it 'interpolates the double array into a string' do
        new_query = ["name = ? and language = ?", "US", 'English']

        query_executor = SqlQueryExecutor::Query::Base.new(new_query, data)
        expect(query_executor.to_sql).to eq double_query
      end

      it 'interpolates the double array into a selector' do
        new_query = ["name = ? and language = ?", "US", 'English']

        query_executor = SqlQueryExecutor::Query::Base.new(new_query, data)
        expect(query_executor.selector).to eq double_selector
      end
    end

    context "query is a hash" do
      let(:query) { { name: "US" } }

      it 'converts hash into a query' do
        query_executor = SqlQueryExecutor::Query::Base.new(query, data)
        expect(query_executor.to_sql).to eq single_query
      end

      it 'converts hash into a selector' do
        query_executor = SqlQueryExecutor::Query::Base.new(query, data)
        expect(query_executor.selector).to eq single_selector
      end

      it 'converts double hash into a query' do
        query[:language] = 'English'

        query_executor = SqlQueryExecutor::Query::Base.new(query, data)
        expect(query_executor.to_sql).to eq double_query
      end

      it 'converts double hash into a selector' do
        query[:language] = 'English'

        query_executor = SqlQueryExecutor::Query::Base.new(query, data)
        expect(query_executor.selector).to eq double_selector
      end

      context 'value is an Array' do
        let(:query) { { name: ["US", "Canada"] } }

        it 'creates an in condition in query' do
          query_executor = SqlQueryExecutor::Query::Base.new(query, data)

          expect(query_executor.to_sql).to eq "name in ('US','Canada')"
        end

        it 'creates an in condition in selector' do
          query_executor = SqlQueryExecutor::Query::Base.new(query, data)
          selector = {"name" => {"$in" => ['US','Canada']}}

          expect(query_executor.selector).to eq selector
        end
      end
    end
  end

  context "Origin selectors" do
    let(:operator_selector) { {:name => {"$ne" => 'US'}} }
    let(:operator_query) { "name != 'US'" }

    it 'converts single selector to sql' do
      query_executor = SqlQueryExecutor::Query::Base.new(single_selector, data)
      expect(query_executor.to_sql).to eq single_query
    end

    it 'keeps single selector' do
      query_executor = SqlQueryExecutor::Query::Base.new(single_selector, data)
      expect(query_executor.selector).to eq single_selector
    end

    it 'converts operator selector to sql' do
      query_executor = SqlQueryExecutor::Query::Base.new(operator_selector, data)
      expect(query_executor.to_sql).to eq operator_query
    end

    it 'keeps operator selector' do
      query_executor = SqlQueryExecutor::Query::Base.new(operator_selector, data)
      expect(query_executor.selector).to eq operator_selector
    end

    it 'converts double selector to sql' do
      query_executor = SqlQueryExecutor::Query::Base.new(double_selector, data)
      expect(query_executor.to_sql).to eq double_query
    end

    it 'keeps double selector' do
      query_executor = SqlQueryExecutor::Query::Base.new(double_selector, data)
      expect(query_executor.selector).to eq double_selector
    end
  end

  context "query has parentheses to define priority" do
    it "respects priority in sql" do
      query = "(monarch = 'The Crown of England' and name = 'US') or (language is null)"
      escaped_query = "(monarch = 'The Crown of England' and name = 'US') or (language is null)"

      query_executor = SqlQueryExecutor::Query::Base.new(query, data)
      expect(query_executor.to_sql).to eq escaped_query
    end

    it "respects priority in selector" do
      query = "(monarch = 'The Crown of England' and name = 'US') or (language is null)"
      selector = {:or=>[{:and=>[{:monarch=>"The Crown of England"}, {:name=>"US"}]}, {"language"=>"nil"}]}

      query_executor = SqlQueryExecutor::Query::Base.new(query, data)
      expect(query_executor.selector).to eq selector
    end
  end
end