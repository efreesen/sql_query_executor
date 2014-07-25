require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor::Operators::Is do
  describe "#execute!" do
    context 'finds elements' do
      let :data do
        [
          OpenStruct.new({id: 1}),
          OpenStruct.new({id: 2}),
          OpenStruct.new({id: 3}),
          OpenStruct.new({id: nil}),
          OpenStruct.new({id: 4}),
          OpenStruct.new({id: 5})
        ]
      end

      context 'is' do
        context 'check null values' do
          it 'returns filtered collection' do
            operator = described_class.new("id is null")
            expect(operator.execute!(data)).to eq([OpenStruct.new({id: nil})])
          end
        end

        context 'check not null values' do
          it 'returns filtered collection' do
            operator = described_class.new("id is 2")
            expect(operator.execute!(data)).to eq([OpenStruct.new({id: 2})])
          end
        end
      end

      context 'is not' do
        context 'check null values' do
          it 'returns filtered collection' do
            operator = described_class.new("id is not null")
            
            expect(operator.execute!(data)).to eq(data - [OpenStruct.new({id: nil})])
          end
        end

        context 'check not null values' do
          it 'returns filtered collection' do
            operator = described_class.new("id is not 2")
            
            expect(operator.execute!(data)).to eq(data - [OpenStruct.new({id: 2})])
          end
        end
      end
    end

    context 'does not find elements' do
      context 'is' do
        let :data do
          [
            OpenStruct.new({id: 1}),
            OpenStruct.new({id: 2}),
            OpenStruct.new({id: 3}),
            OpenStruct.new({id: 4}),
            OpenStruct.new({id: 5})
          ]
        end

        context 'check null values' do
          it 'returns empty array' do
            operator = described_class.new("id is null")
            expect(operator.execute!(data)).to eq([])
          end
        end

        context 'check not null values' do
          it 'returns empty array' do
            operator = described_class.new("id is 8")
            expect(operator.execute!(data)).to eq([])
          end
        end
      end

      context 'is not' do
        context 'check null values' do
          let :data do
            [
              OpenStruct.new({id: nil}),
              OpenStruct.new({id: nil}),
              OpenStruct.new({id: nil}),
              OpenStruct.new({id: nil}),
              OpenStruct.new({id: nil})
            ]
          end

          it 'returns filtered collection' do
            operator = described_class.new("id is not null")
            
            expect(operator.execute!(data)).to eq([])
          end
        end

        context 'check not null values' do
          let :data do
            [
              OpenStruct.new({id: 2}),
              OpenStruct.new({id: 2}),
              OpenStruct.new({id: 2}),
              OpenStruct.new({id: 2}),
              OpenStruct.new({id: 2})
            ]
          end

          it 'returns filtered collection' do
            operator = described_class.new("id is not 2")
            
            expect(operator.execute!(data)).to eq([])
          end
        end
      end
    end
  end

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
end
