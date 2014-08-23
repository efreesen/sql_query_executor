require 'spec_helper'
require 'sql_query_executor/query/normalizers/query_normalizer'

describe SqlQueryExecutor::Query::Normalizers::QueryNormalizer do
  describe '.execute' do
    context 'query is a String' do
      let!(:query) { 'monarch = "Crown of england"' }

      subject { described_class.execute(query) }

      it 'adds separators' do
        expect(subject).to eq 'monarch$QS$=$QS$"Crown$SS$of$SS$england"'
      end
    end

    context 'query is an Array' do
      context 'when all elements are strings' do
        let!(:query) { ['monarch = ?', "Crown of england"] }

        subject { described_class.execute(query) }

        it 'returns a String' do
          expect(subject).to be_a(String)
        end

        it 'converts correctly' do
          expect(subject).to eq("monarch$QS$=$QS$'Crown$SS$of$SS$england'")
        end
      end

      context 'when second element is a Hash' do
        let!(:query) { ['monarch = :name', name: "Crown of england"] }

        subject { described_class.execute(query) }

        it 'returns a String' do
          expect(subject).to be_a(String)
        end

        it 'converts correctly' do
          expect(subject).to eq("monarch$QS$=$QS$'Crown$SS$of$SS$england'")
        end
      end
    end

    context 'query is a Hash' do
      let!(:query) { {monarch: "Crown of england"} }

      subject { described_class.execute(query) }

      it 'returns a String' do
        expect(subject).to be_a(String)
      end

      it 'converts correctly' do
        expect(subject).to eq("monarch$QS$=$QS$'Crown$SS$of$SS$england'")
      end
    end

    context 'query has date parameters' do
      let!(:today) { Date.today }
      let!(:query) { { updated_at: {'$gt' => today} } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("updated_at$QS$>$QS$'#{today.strftime('%Y-%m-%d')}'")
      end
    end

    context 'query has time parameters' do
      let!(:today) { Time.now }
      let!(:query) { { updated_at: {'$gt' => today} } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("updated_at$QS$>$QS$'#{today.strftime('%Y-%m-%d$SS$%H:%M:%S$SS$%z')}'")
      end
    end

    context 'query has integer parameters' do
      let!(:today) { Date.today }
      let!(:query) { { id: 1 } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("id$QS$=$QS$1")
      end
    end

    context 'query has array parameters' do
      let!(:query) { { '$and' => [{ id: [1, 2] }, { name: 'John'} ] } }

      subject { described_class.execute(query) }

      it 'converts correctly' do
        expect(subject).to eq("(id$QS$in$QS$(1,2) and$QS$name$QS$=$QS$'John')")
      end
    end
  end

  describe 'clean_query' do
    context 'query is a String' do
      it 'adds separators' do
        query = 'monarch = "Crown of england"'

        expect(described_class.clean_query(query)).to eq 'monarch = "Crown of england"'
      end

      it 'remove quotes from null' do
        query = 'monarch is not "null"'

        expect(described_class.clean_query(query)).to eq 'monarch is not null'
      end
    end

    context 'query is an Array' do
      let!(:query) { ['monarch = ?', "Crown of england"] }

      subject { described_class.clean_query(query) }

      it 'returns a String' do
        expect(subject).to be_a(String)
      end

      it 'converts correctly' do
        expect(subject).to eq("monarch = 'Crown of england'")
      end
    end

    context 'query is a Hash' do
      let!(:query) { {monarch: "Crown of england"} }

      subject { described_class.clean_query(query) }

      it 'returns a String' do
        expect(subject).to be_a(String)
      end

      it 'converts correctly' do
        expect(subject).to eq("monarch = 'Crown of england'")
      end
    end

    context 'nested query' do
      let!(:query) { {'$and' => [{monarch: "Crown of england"}, {name: 'Canada'}] } }

      subject { described_class.clean_query(query) }

      it 'returns a String' do
        expect(subject).to be_a(String)
      end

      it 'converts correctly' do
        expect(subject).to eq("(monarch = 'Crown of england' and name = 'Canada')")
      end
    end

    context 'complex query' do
      let!(:query) { {'$and' => [{monarch: "Crown of england"}, {name: 'Canada'}, {'$or' => [{monarch: nil}, {name: 'Brazil'}]}] } }

      subject { described_class.clean_query(query) }

      it 'returns a String' do
        expect(subject).to be_a(String)
      end

      it 'converts correctly' do
        expect(subject).to eq("(monarch = 'Crown of england' and name = 'Canada' and (monarch is null or name = 'Brazil'))")
      end
    end
  end

  describe '.attributes_from_query' do
    context 'empty query' do
      let!(:query) { '' }
      let!(:selector) { {} }

      subject { described_class.attributes_from_query(query) }

      it 'converts correctly' do
        expect(subject).to eq(selector)
      end
    end

    context 'single query' do
      context 'when value is a string' do
        let!(:query) { 'monarch = "Crown of england"' }
        let!(:selector) { {monarch: "Crown of england"} }

        subject { described_class.attributes_from_query(query) }

        it 'converts correctly' do
          expect(subject).to eq(selector)
        end
      end

      context 'when value is an integer' do
        let!(:query) { 'id = 1' }
        let!(:selector) { {id: 1} }

        subject { described_class.attributes_from_query(query) }

        it 'converts correctly' do
          expect(subject).to eq(selector)
        end
      end

      context 'when value is a date' do
        let!(:today) { Date.today }
        let!(:query) { "created_at = '#{today.strftime('%Y-%m-%d')}'" }
        let!(:selector) { {created_at: today} }

        subject { described_class.attributes_from_query(query) }

        it 'converts correctly' do
          expect(subject).to eq(selector)
        end
      end

      context 'when value is a time' do
        let!(:now) { Time.now }
        let!(:query) { "created_at = '#{now.strftime('%Y-%m-%d %H:%M:%S %z')}'" }
        let!(:selector) { {created_at: now} }

        subject { described_class.attributes_from_query(query) }

        it 'converts correctly' do
          expect(subject.to_s).to eq(selector.to_s)
        end
      end

      context 'when value is an array' do
        let!(:query) { "name in ('Canada', 'Russia')" }

        subject { described_class.attributes_from_query(query) }

        it 'converts correctly' do
          expect(subject).to eq({})
        end
      end

      context 'when value is a hash' do
        let!(:query) { "name <> 'Canada'" }

        subject { described_class.attributes_from_query(query) }

        it 'converts correctly' do
          expect(subject).to eq({})
        end
      end
    end

    context 'multiple queries' do
      let!(:query) { 'name = "US" and monarch = "Crown of england"' }
      let!(:selector) { {name: 'US', monarch: "Crown of england"} }

      subject { described_class.attributes_from_query(query) }

      it 'converts correctly' do
        expect(subject).to eq(selector)
      end
    end

    context 'nested queries' do
      let!(:selector) { {name: 'US', '$and' => [{id: 1}, {monarch: "Crown of england"}] } }
      let!(:attributes) { {name: 'US', id: 1, monarch: "Crown of england"}  }

      subject { described_class.attributes_from_query(selector) }

      it 'converts correctly' do
        expect(subject).to eq(attributes)
      end
    end

    context 'complex queries' do
      let!(:selector) { {name: 'US', '$and' => [{id: 1}, '$or' => [{name: 'Brazil'}, {monarch: "Crown of england"}]] } }
      let!(:attributes) { {name: 'US', id: 1} }

      subject { described_class.attributes_from_query(selector) }

      it 'converts correctly' do
        expect(subject).to eq(attributes)
      end
    end
  end
end
