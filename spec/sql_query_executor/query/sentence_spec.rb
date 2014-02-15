require 'spec_helper'
require 'sql_query_executor/query/sentence'

describe SqlQueryExecutor::Query::Sentence do
  let(:data) { [] }

  describe "initialize" do
    context "when single query" do
      context "and Default Operator" do
        let(:query) { "name = \"US\"" }
        subject { described_class.new(query, data) }

        its(:query) { should == query }
        its(:operator) { should be_a SqlQueryExecutor::Operators::Default }
      end

      context "and Between Operator" do
        let(:query) { "created_at between '2013-12-31' and '2014-01-12'" }
        subject { described_class.new(query, data) }

        its(:operator) { should be_a SqlQueryExecutor::Operators::Between }
      end

      context "and Is Operator" do
        let(:query) { "language is null" }
        subject { described_class.new(query, data) }

        its(:operator) { should be_a SqlQueryExecutor::Operators::Is }
      end

      context "and In Operator" do
        let(:query) { "language in ('English', 'Spanish')" }
        subject { described_class.new(query, data) }

        its(:operator) { should be_a SqlQueryExecutor::Operators::In }
      end
    end
  end
end
