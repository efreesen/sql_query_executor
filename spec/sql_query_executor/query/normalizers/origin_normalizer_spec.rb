require 'spec_helper'
require 'sql_query_executor/query/normalizers/origin_normalizer'

describe SqlQueryExecutor::Query::Normalizers::OriginNormalizer do
  describe '.execute' do
    context 'single selector' do
      context 'when value is a string' do
        let(:selector) { {monarch: "Crown of england"} }
        let(:query) { "monarch = 'Crown of england'" }

        subject { described_class.execute(selector) }

        it 'returns a string' do
          expect(subject).to be_a String
        end

        it 'converts correctly' do
          expect(subject).to eq(query)
        end
      end

      context 'when value is an empty string' do
        let(:selector) { {id: ""} }
        let(:query) { "id = ''" }

        subject { described_class.execute(selector) }

        it 'converts correctly' do
          expect(subject).to eq(query)
        end
      end

      context 'when value is an integer' do
        let(:selector) { {id: 1} }
        let(:query) { "id = 1" }

        subject { described_class.execute(selector) }

        it 'converts correctly' do
          expect(subject).to eq(query)
        end
      end

      context 'when value is a date' do
        let(:today) { Date.today }
        let(:selector) { {created_at: today} }
        let(:query) { "created_at = '#{today.strftime('%Y-%m-%d')}'" }

        subject { described_class.execute(selector) }

        it 'converts correctly' do
          expect(subject).to eq(query)
        end
      end

      context 'when value is a time' do
        let(:now) { Time.now }
        let(:selector) { {created_at: now} }
        let(:query) { "created_at = '#{now.strftime('%Y-%m-%d %H:%M:%S %z')}'" }

        subject { described_class.execute(selector) }

        it 'converts correctly' do
          expect(subject).to eq(query)
        end
      end

      context 'when value is an array' do
        let(:selector) { {name: ['Canada', 'Russia']} }
        let(:query) { "name in ('Canada','Russia')" }

        subject { described_class.execute(selector) }

        it 'converts correctly' do
          expect(subject).to eq(query)
        end
      end

      context 'when value is a hash' do
        let(:selector) { {name: {'$ne' => 'Canada'}} }
        let(:query) { "name <> 'Canada'" }

        subject { described_class.execute(selector) }

        it 'converts correctly' do
          expect(subject).to eq(query)
        end
      end
    end

    context 'multiple selectors' do
      let(:selector) { {name: 'US', monarch: "Crown of england"} }
      let(:query) { "name = 'US' and monarch = 'Crown of england'" }

      subject { described_class.execute(selector) }

      it 'converts correctly' do
        expect(subject).to eq(query)
      end
    end

    context 'nested selectors' do
      let(:selector) { {name: 'US', '$and' => [{id: 1}, {monarch: "Crown of england"}] } }
      let(:query) { "name = 'US' and (id = 1 and monarch = 'Crown of england')" }

      subject { described_class.execute(selector) }

      it 'converts correctly' do
        expect(subject).to eq(query)
      end
    end

    context 'complex selectors' do
      let(:selector) { {name: 'US', '$and' => [{id: 1}, '$or' => [{name: 'Brazil'}, {monarch: "Crown of england"}]] } }
      let(:query) { "name = 'US' and (id = 1 and (name = 'Brazil' or monarch = 'Crown of england'))" }

      subject { described_class.execute(selector) }

      it 'converts correctly' do
        expect(subject).to eq(query)
      end
    end
  end

  describe '.attributes_from_query' do
    context 'single selector' do
      context 'when value is a string' do
        let(:selector) { {monarch: "Crown of england"} }

        subject { described_class.attributes_from_query(selector) }

        it 'converts correctly' do
          expect(subject).to eq(selector)
        end
      end

      context 'when value is an integer' do
        let(:selector) { {id: 1} }

        subject { described_class.attributes_from_query(selector) }

        it 'converts correctly' do
          expect(subject).to eq(selector)
        end
      end

      context 'when value is a date' do
        let(:today) { Date.today }
        let(:selector) { {created_at: today} }

        subject { described_class.attributes_from_query(selector) }

        it 'converts correctly' do
          expect(subject).to eq(selector)
        end
      end

      context 'when value is a time' do
        let(:now) { Time.now }
        let(:selector) { {created_at: now} }

        subject { described_class.attributes_from_query(selector) }

        it 'converts correctly' do
          expect(subject).to eq(selector)
        end
      end

      context 'when value is an array' do
        let(:selector) { {name: ['Canada', 'Russia']} }

        subject { described_class.attributes_from_query(selector) }

        it 'converts correctly' do
          expect(subject).to eq({})
        end
      end

      context 'when value is a hash' do
        let(:selector) { {name: {'$ne' => 'Canada'}} }

        subject { described_class.attributes_from_query(selector) }

        it 'converts correctly' do
          expect(subject).to eq({})
        end
      end
    end

    context 'multiple selectors' do
      let(:selector) { {name: 'US', monarch: "Crown of england"} }

      subject { described_class.attributes_from_query(selector) }

      it 'converts correctly' do
        expect(subject).to eq(selector)
      end
    end

    context 'nested selectors' do
      let(:selector) { {name: 'US', '$and' => [{id: 1}, {monarch: "Crown of england"}] } }
      let(:attributes) { {name: 'US', id: 1, monarch: "Crown of england"}  }

      subject { described_class.attributes_from_query(selector) }

      it 'converts correctly' do
        expect(subject).to eq(attributes)
      end
    end

    context 'complex selectors' do
      let(:selector) { {name: 'US', '$and' => [{id: 1}, '$or' => [{name: 'Brazil'}, {monarch: "Crown of england"}]] } }
      let(:attributes) { {name: 'US', id: 1} }

      subject { described_class.attributes_from_query(selector) }

      it 'converts correctly' do
        expect(subject).to eq(attributes)
      end
    end
  end
end
