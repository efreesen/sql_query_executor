require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::In do
  describe "#selector" do
    subject { described_class.new("id in (2,4)") }

    it 'converts query' do
      expect(subject.selector).to eq({'id' => {'$in' => [2, 4]}})
    end
  end

  describe "#logic" do
    subject { described_class.new("id in (2,4)") }

    context 'when is not a hash' do
      it 'converts query' do
        expect(subject.logic).to eq('[2, 4].include?(id)')
      end
    end

    context 'when is a hash' do
      it 'converts query' do
        expect(subject.logic(true)).to eq('[2, 4].include?(self[:id])')
      end
    end
  end
end
