require 'spec_helper'
require 'sql_query_executor/query/sentence'

describe SqlQueryExecutor::Query::Sentence do
  let(:data) { [
                 OpenStruct.new({name: 'US',      language: 'English',    created_at: Date.new(2014,01,05)}),
                 OpenStruct.new({name: 'Brazil',  language: 'Portuguese', created_at: Date.new(2014,01,20)}),
                 OpenStruct.new({name: 'Morocco', language: 'Arabic',     created_at: Date.new(2014,01,11)}),
                 OpenStruct.new({name: 'Mexico',  language: 'Spanish',    created_at: Date.new(2014,01,27)}),
                 OpenStruct.new({name: 'Extinct', language: nil,          created_at: Date.new(2014,01,29)}),
               ] }

  context "when single query" do
    context "and Default Operator" do
      let(:query) { "name = \"US\"" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'execute!' do
        it 'returns filtered collection' do
          expect(subject.execute!(data)).to eq [data.first]
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"name"=>"US"})
        end
      end
    end

    context "and Between Operator" do
      let(:query) { "created_at between '2013-12-31' and '2014-01-12'" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'execute!' do
        it 'returns filtered collection' do
          expect(subject.execute!(data)).to eq [data.first, data[2]]
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"created_at"=>{"$gte"=>Date.new(2013,12,31), "$lte"=>Date.new(2014,01,12)}})
        end
      end
    end

    context "and Is Operator" do
      let(:query) { "language is null" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'execute1' do
        it 'returns filtered collection' do
          expect(subject.execute!(data)).to eq [data.last]
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"language"=>nil})
        end
      end
    end

    context "and In Operator" do
      let(:query) { "language in ('English','Spanish')" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'execute!' do
        it 'returns filtered collection' do
          expect(subject.execute!(data)).to eq [data.first, data[3]]
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"language"=>{"$in"=>["English", "Spanish"]}})
        end
      end
    end
  end
end
