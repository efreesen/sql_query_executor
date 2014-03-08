require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::Default do
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

    context '=' do
      context 'finds element' do
        subject { described_class.new("id = 2", data) }

        it 'returns filtered collection' do
          expect(subject.execute!).to eq([OpenStruct.new({id: 2})])
        end
      end

      context 'does not find element' do
        subject { described_class.new("id = 9", data) }

        it 'returns empty array' do
          expect(subject.execute!).to eq([])
        end
      end
    end

    context '>' do
      context 'finds element' do
        subject { described_class.new("id > 4", data) }

        it 'returns filtered collection' do
          expect(subject.execute!).to eq([OpenStruct.new({id: 5})])
        end
      end

      context 'does not find element' do
        subject { described_class.new("id > 9", data) }

        it 'returns empty array' do
          expect(subject.execute!).to eq([])
        end
      end
    end

    context '<' do
      context 'finds element' do
        subject { described_class.new("id < 2", data) }

        it 'returns filtered collection' do
          expect(subject.execute!).to eq([OpenStruct.new({id: 1})])
        end
      end

      context 'does not find element' do
        subject { described_class.new("id < 1", data) }

        it 'returns empty array' do
          expect(subject.execute!).to eq([])
        end
      end
    end

    context '>=' do
      context 'finds element' do
        subject { described_class.new("id >= 5", data) }

        it 'returns filtered collection' do
          expect(subject.execute!).to eq([OpenStruct.new({id: 5})])
        end
      end

      context 'does not find element' do
        subject { described_class.new("id >= 6", data) }

        it 'returns empty array' do
          expect(subject.execute!).to eq([])
        end
      end
    end

    context '<=' do
      context 'finds element' do
        subject { described_class.new("id <= 1", data) }

        it 'returns filtered collection' do
          expect(subject.execute!).to eq([OpenStruct.new({id: 1})])
        end
      end

      context 'does not find element' do
        subject { described_class.new("id <= 0", data) }

        it 'returns empty array' do
          expect(subject.execute!).to eq([])
        end
      end
    end

    context '!=' do
      context 'finds element' do
        subject { described_class.new("id != 1", data) }

        it 'returns filtered collection' do
          expect(subject.execute!).to eq(data - [OpenStruct.new({id: 1})])
        end
      end

      context 'does not find element' do
        let :data do
          [
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1})
          ]
        end

        subject { described_class.new("id != 1", data) }

        it 'returns empty array' do
          expect(subject.execute!).to eq([])
        end
      end
    end

    context '<>' do
      context 'finds element' do
        subject { described_class.new("id <> 1", data) }

        it 'returns filtered collection' do
          expect(subject.execute!).to eq(data - [OpenStruct.new({id: 1})])
        end
      end

      context 'does not find element' do
        let :data do
          [
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 1})
          ]
        end

        subject { described_class.new("id <> 1", data) }

        it 'returns empty array' do
          expect(subject.execute!).to eq([])
        end
      end
    end
  end

  describe "#selector" do
    context '=' do
      subject { described_class.new("id = 2", []) }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => 2})
      end
    end

    context '>' do
      subject { described_class.new("id > 2", []) }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$gt' => 2}})
      end
    end

    context '<' do
      subject { described_class.new("id < 2", []) }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$lt' => 2}})
      end
    end

    context '>=' do
      subject { described_class.new("id >= 2", []) }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$gte' => 2}})
      end
    end

    context '<=' do
      subject { described_class.new("id <= 2", []) }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$lte' => 2}})
      end
    end

    context '!=' do
      subject { described_class.new("id != 2", []) }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$ne' => 2}})
      end
    end

    context '<>' do
      subject { described_class.new("id <> 2", []) }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$ne' => 2}})
      end
    end
  end
end
