require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::Is do
  describe "#selector" do
    context 'is' do
      context 'check null values' do
        subject { described_class.new("id is null") }

        it 'converts query' do
          expect(subject.selector).to eq({'id' => nil})
        end
      end

      context 'check not null values' do
        subject { described_class.new("id is 2") }

        it 'converts query' do
          expect(subject.selector).to eq({'id' => 2})
        end
      end
    end

    context 'is not' do
      context 'check null values' do
        subject { described_class.new("id is not null") }

        it 'converts query' do
          expect(subject.selector).to eq({"id"=>{"$ne"=>nil}})
        end
      end

      context 'check not null values' do
        subject { described_class.new("id is not 2") }

        it 'converts query' do
          expect(subject.selector).to eq({"id"=>{"$ne"=>2}})
        end
      end
    end
  end

  describe "#logic" do
    context 'when is not a hash' do
      context 'is' do
        context 'check null values' do
          subject { described_class.new("id is null") }

          it 'converts query' do
            expect(subject.logic).to eq('id == nil')
          end
        end

        context 'check not null values' do
          subject { described_class.new("id is 2") }

          it 'converts query' do
            expect(subject.logic).to eq('id == 2')
          end
        end
      end

      context 'is not' do
        context 'check null values' do
          subject { described_class.new("id is not null") }

          it 'converts query' do
            expect(subject.logic).to eq("id != nil")
          end
        end

        context 'check not null values' do
          subject { described_class.new("id is not 2") }

          it 'converts query' do
            expect(subject.logic).to eq("id != 2")
          end
        end
      end
    end

    context 'when is a hash' do
      context 'is' do
        context 'check null values' do
          subject { described_class.new("id is null") }

          it 'converts query' do
            expect(subject.logic(true)).to eq('self[:id] == nil')
          end
        end

        context 'check not null values' do
          subject { described_class.new("id is 2") }

          it 'converts query' do
            expect(subject.logic(true)).to eq('self[:id] == 2')
          end
        end
      end

      context 'is not' do
        context 'check null values' do
          subject { described_class.new("id is not null") }

          it 'converts query' do
            expect(subject.logic(true)).to eq("self[:id] != nil")
          end
        end

        context 'check not null values' do
          subject { described_class.new("id is not 2") }

          it 'converts query' do
            expect(subject.logic(true)).to eq("self[:id] != 2")
          end
        end
      end
    end
  end
end
