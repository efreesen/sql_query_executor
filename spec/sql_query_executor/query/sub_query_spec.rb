require 'spec_helper'
require 'sql_query_executor/query/sub_query'

describe SqlQueryExecutor::Query::SubQuery do
  let(:data) { [
                 OpenStruct.new({id: 1, name: 'US',      language: 'English',    created_at: Date.new(2014,01,05)}),
                 OpenStruct.new({id: 2, name: 'Brazil',  language: 'Portuguese', created_at: Date.new(2014,01,20)}),
                 OpenStruct.new({id: 3, name: 'Morocco', language: 'Arabic',     created_at: Date.new(2014,01,11)}),
                 OpenStruct.new({id: 4, name: 'Mexico',  language: 'Spanish',    created_at: Date.new(2014,01,27)}),
                 OpenStruct.new({id: 5, name: 'Extinct', language: nil,          created_at: Date.new(2014,01,29)}),
               ] }

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

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"name"=>"US"})
        end
      end

      context 'execute!' do
        it 'returns filtered collection' do
          expect(subject.execute!).to eq([data.first])
        end
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

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({:and=>[{:and=>[{"name"=>"US"}, {"id"=>1}]}, {"language"=>"English"}]})
        end
      end

      context 'execute!' do
        it 'returns filtered collection' do
          expect(subject.execute!).to eq([data.first])
        end
      end
    end

    context "when has a complex sub_query" do
      let(:query) { "((name$QS$=$QS$\"US\"$QS$and$QS$id$QS$=$QS$1)$QS$or$QS$(name$QS$=$QS$\"Brazil\")) and$QS$created_at$QS$>$QS$\"2014-01-04\"" }
      let(:clean_query) { "((name = \"US\" and id = 1) or (name = \"Brazil\")) and created_at > \"2014-01-04\"" }
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

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({:and=>[{:or=>[{:and=>[{"name"=>"US"}, {"id"=>1}]}, {"name"=>"Brazil"}]}, {"created_at"=>{'$gt' => Date.new(2014,01,04)}}]})
        end
      end

      context 'execute!' do
        it 'returns filtered collection' do
          expect(subject.execute!).to eq([data.first, data[1]])
        end
      end
    end
  end
end
