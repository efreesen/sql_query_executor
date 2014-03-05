require 'spec_helper'
require 'sql_query_executor/query/sub_query'

describe SqlQueryExecutor::Query::SubQuery do
  let(:data) { [] }

  describe "initialize" do
    context "when has a sentence" do
      let!(:query) { "name$QS$=$QS$\"US\"" }
      let!(:clean_query) { "name = \"US\"" }
      subject { described_class.new(query, data) }

      its(:kind) { should == :sentence }
      its(:to_sql) { should == clean_query }

      it "has one children" do
        expect(subject.children.size).to eq 1
      end

      it "children is a Sentence" do
        expect(subject.children.first.class.name).to eq "SqlQueryExecutor::Query::Sentence"
      end
    end

    context "when has a sub_query" do
      let(:query) { "(name$QS$=$QS$\"US\"$QS$and$QS$id$QS$=$QS$1) and$QS$language$QS$=$QS$\"English\"" }
      let(:clean_query) { "(name = \"US\" and id = 1) and language = \"English\"" }
      subject { described_class.new(query, data) }

      its(:kind) { should == :sub_query }
      its(:to_sql) { should == clean_query }

      it "has 2 children" do
        expect(subject.children.size).to eq 2
      end

      it "children are a SubQueries" do
        expect(subject.children.first).to be_a SqlQueryExecutor::Query::SubQuery
        expect(subject.children.last).to be_a SqlQueryExecutor::Query::SubQuery
      end
    end

    context "when has a complex sub_query" do
      let(:query) { "((name$QS$=$QS$\"US\"$QS$and$QS$id$QS$=$QS$1)$QS$or$QS$(name$QS$=$QS$\"Brazil\")) and$QS$language$QS$=$QS$\"English\"" }
      let(:clean_query) { "((name = \"US\" and id = 1) or (name = \"Brazil\")) and language = \"English\"" }
      subject { described_class.new(query, data) }

      its(:kind) { should == :sub_query }
      its(:to_sql) { should == clean_query }

      it "has 2 children" do
        expect(subject.children.size).to eq 2
      end

      it "children are a SubQueries" do
        subject.children.each do |child|
          expect(child).to be_a SqlQueryExecutor::Query::SubQuery
        end
      end
    end
  end
end
