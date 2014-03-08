require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::In do
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

    context 'finds elements' do
      subject { described_class.new("id in (2,4)", data) }

      it 'returns filtered collection' do
        expect(subject.execute!).to eq([OpenStruct.new({id: 2}), OpenStruct.new({id: 4})])
      end
    end

    context 'does not find elements' do
      subject { described_class.new("id in (7,9)", data) }

      it 'returns empty array' do
        expect(subject.execute!).to eq([])
      end
    end
  end

  describe "#selector" do
    subject { described_class.new("id in (2,4)", []) }

    it 'converts query' do
      expect(subject.selector).to eq({'id' => {'$in' => [2, 4]}})
    end
  end
end
