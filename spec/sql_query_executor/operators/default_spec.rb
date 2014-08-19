require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::Default do
  describe "#selector" do
    context '=' do
      subject { described_class.new("id = 2") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => 2})
      end
    end

    context '>' do
      subject { described_class.new("id > 2") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$gt' => 2}})
      end
    end

    context '<' do
      subject { described_class.new("id < 2") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$lt' => 2}})
      end
    end

    context '>=' do
      subject { described_class.new("id >= 2") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$gte' => 2}})
      end
    end

    context '<=' do
      subject { described_class.new("id <= 2") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$lte' => 2}})
      end
    end

    context '!=' do
      subject { described_class.new("id != 2") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$ne' => 2}})
      end
    end

    context '<>' do
      subject { described_class.new("id <> 2") }

      it 'converts query' do
        expect(subject.selector).to eq({'id' => {'$ne' => 2}})
      end
    end
  end

  describe "#logic" do
    context 'when is not a hash' do
      context '=' do
        subject { described_class.new("id = 2") }

        it 'converts query' do
          expect(subject.logic).to eq('id == 2')
        end
      end

      context '>' do
        subject { described_class.new("id > 2") }

        it 'converts query' do
          expect(subject.logic).to eq('id > 2')
        end
      end

      context '<' do
        subject { described_class.new("id < 2") }

        it 'converts query' do
          expect(subject.logic).to eq('id < 2')
        end
      end

      context '>=' do
        subject { described_class.new("id >= 2") }

        it 'converts query' do
          expect(subject.logic).to eq('id >= 2')
        end
      end

      context '<=' do
        subject { described_class.new("id <= 2") }

        it 'converts query' do
          expect(subject.logic).to eq('id <= 2')
        end
      end

      context '!=' do
        subject { described_class.new("id != 2") }

        it 'converts query' do
          expect(subject.logic).to eq('id != 2')
        end
      end

      context '<>' do
        subject { described_class.new("id <> 2") }

        it 'converts query' do
          expect(subject.logic).to eq('id != 2')
        end
      end
    end

    context 'when is a hash' do
      context '=' do
        subject { described_class.new("id = 2") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] == 2')
        end
      end

      context '>' do
        subject { described_class.new("id > 2") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] > 2')
        end
      end

      context '<' do
        subject { described_class.new("id < 2") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] < 2')
        end
      end

      context '>=' do
        subject { described_class.new("id >= 2") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] >= 2')
        end
      end

      context '<=' do
        subject { described_class.new("id <= 2") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] <= 2')
        end
      end

      context '!=' do
        subject { described_class.new("id != 2") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] != 2')
        end
      end

      context '<>' do
        subject { described_class.new("id <> 2") }

        it 'converts query' do
          expect(subject.logic(true)).to eq('self[:id] != 2')
        end
      end
    end
  end
end
