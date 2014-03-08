require 'spec_helper'
require 'sql_query_executor/query/query_normalizer'

describe SqlQueryExecutor::Query::QueryNormalizer do
  describe '.execute' do
    context 'query is a String' do
      let(:query) { 'monarch = "Crown of england"' }

      subject { described_class.execute(query) }

      it 'adds separators' do
        expect(subject).to eq 'monarch$QS$=$QS$"Crown$SS$of$SS$england"'
      end
    end

    context 'query is an Array' do
      let(:query) { ['monarch = ?', "Crown of england"] }

      subject { described_class.execute(query) }

      its(:class) { should eq String }

      it 'converts correctly' do
        expect(subject).to eq("monarch$QS$=$QS$'Crown$SS$of$SS$england'")
      end
    end

    context 'query is a Hash' do
      let(:query) { {monarch: "Crown of england"} }

      subject { described_class.execute(query) }

      its(:class) { should eq String }

      it 'converts correctly' do
        expect(subject).to eq("monarch$QS$=$QS$'Crown$SS$of$SS$england'")
      end
    end

    context 'query has date parameters' do
      let(:today) { Date.today }
      let(:query) { { updated_at: {'$gt' => today} } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("updated_at$QS$>$QS$'#{today.strftime('%Y-%m-%d')}'")
      end
    end

    context 'query has time parameters' do
      let(:today) { Time.now }
      let(:query) { { updated_at: {'$gt' => today} } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("updated_at$QS$>$QS$'#{today.strftime('%Y-%m-%d$SS$%H:%M:%S$SS$%z')}'")
      end
    end

    context 'query has integer parameters' do
      let(:today) { Date.today }
      let(:query) { { id: 1 } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("id$QS$=$QS$1")
      end
    end

    context 'query has array parameters' do
      let(:query) { { '$and' => [{ id: [1, 2] }, { name: 'John'} ] } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("(id$QS$in$QS$(1,2) and$QS$name$QS$=$QS$'John')")
      end
    end
  end

  describe 'clean_query' do
    context 'query is a String' do
      let(:query) { 'monarch = "Crown of england"' }

      subject { described_class.clean_query(query) }

      it 'adds separators' do
        expect(subject).to eq 'monarch = "Crown of england"'
      end
    end

    context 'query is an Array' do
      let(:query) { ['monarch = ?', "Crown of england"] }

      subject { described_class.clean_query(query) }

      its(:class) { should eq String }

      it 'converts correctly' do
        expect(subject).to eq("monarch = 'Crown of england'")
      end
    end

    context 'query is a Hash' do
      let(:query) { {monarch: "Crown of england"} }

      subject { described_class.clean_query(query) }

      its(:class) { should eq String }

      it 'converts correctly' do
        expect(subject).to eq("monarch = 'Crown of england'")
      end
    end

    context 'nested query' do
      let(:query) { {'$and' => [{monarch: "Crown of england"}, {name: 'Canada'}] } }

      subject { described_class.clean_query(query) }

      its(:class) { should eq String }

      it 'converts correctly' do
        expect(subject).to eq("(monarch = 'Crown of england' and name = 'Canada')")
      end
    end

    context 'complex query' do
      let(:query) { {'$and' => [{monarch: "Crown of england"}, {name: 'Canada'}, {'$or' => [{monarch: nil}, {name: 'Brazil'}]}] } }

      subject { described_class.clean_query(query) }

      its(:class) { should eq String }

      it 'converts correctly' do
        expect(subject).to eq("(monarch = 'Crown of england' and name = 'Canada' and (monarch is null or name = 'Brazil'))")
      end
    end
  end
end
