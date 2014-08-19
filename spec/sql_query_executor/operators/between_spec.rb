require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::Between do
  describe "#selector" do
    context 'when values are integer' do
      subject { described_class.new("id between 2 and 4") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$gte' => 2, '$lte' => 4}})
      end
    end

    context 'when values are float' do
      subject { described_class.new("id between 2.3 and 2.4") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$gte' => 2.3, '$lte' => 2.4}})
      end
    end

    context 'when values are dates' do
      subject { described_class.new("id between '2014-01-01' and '2014-01-31'") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$gte' => Date.new(2014,01,01), '$lte' => Date.new(2014,01,31)}})
      end
    end
  end

  describe "#logic" do
    context 'when is not a hash' do
      context 'and values are integer' do
        subject { described_class.new("id between 2 and 4") }

        it 'converts query' do
          expect(subject.logic).to eq('id >= 2 && id <= 4')
        end
      end

      context 'and values are float' do
        subject { described_class.new("id between 2.3 and 2.4") }

        it 'converts query' do
          expect(subject.logic).to eq('id >= 2.3 && id <= 2.4')
        end
      end

      context 'and values are dates' do
        subject { described_class.new("id between '2014-01-01' and '2014-01-31'") }

        it 'converts query' do
          expect(subject.logic).to eq('id >= Date.new(2014, 1, 1) && id <= Date.new(2014, 1, 31)')
        end
      end
    end

    context 'when is a hash' do
      context 'and values are integer' do
        subject { described_class.new("id between 2 and 4") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] >= 2 && self[:id] <= 4')
        end
      end

      context 'and values are float' do
        subject { described_class.new("id between 2.3 and 2.4") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] >= 2.3 && self[:id] <= 2.4')
        end
      end

      context 'and values are dates' do
        subject { described_class.new("id between '2014-01-01' and '2014-01-31'") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] >= Date.new(2014, 1, 1) && self[:id] <= Date.new(2014, 1, 31)')
        end
      end
    end
  end
end
