require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::Between do
  describe "#execute!" do
    let :data do
      [
        OpenStruct.new({id: 1}),
        OpenStruct.new({id: 2}),
        OpenStruct.new({id: 3}),
        OpenStruct.new({id: '3.46'}),
        OpenStruct.new({id: 4}),
        OpenStruct.new({id: 5})
      ]
    end

    context 'finds element' do
      subject { described_class.new("id between 2 and 4") }

      it 'returns filtered collection' do
        expect(subject.execute!(data)).to eq([OpenStruct.new({id: 2}), OpenStruct.new({id: 3}), OpenStruct.new({id: 4})])
      end
    end

    context 'does not find element' do
      context 'range out of reach' do
        it 'returns filtered collection' do
          operator = described_class.new("id between 8 and 10")
          expect(operator.execute!(data)).to eq([])
        end
      end

      context 'range overlaps' do
        it 'returns empty array' do
          operator = described_class.new("id between 5 and 3")
          expect(operator.execute!(data)).to eq([])
        end
      end
    end
  end

  describe "#selector" do
    subject { described_class.new("id between 2 and 4") }

    it 'converts query' do
      expect(subject.selector).to eq({'id' => {'$gte' => 2, '$lte' => 4}})
    end
  end
end
