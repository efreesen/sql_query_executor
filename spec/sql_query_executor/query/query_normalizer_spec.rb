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

    context 'query has integer parameters' do
      let(:today) { Date.today }
      let(:query) { { id: 1 } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("id$QS$=$QS$1")
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
      let(:query) { [monarch: "Crown of england"] }

      subject { described_class.clean_query(query) }

      its(:class) { should eq String }

      it 'converts correctly' do
        expect(subject).to eq("monarch = 'Crown of england'")
      end
    end
  end
end
