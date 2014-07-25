require 'spec_helper'

require 'sql_query_executor'
require 'sql_query_executor/base'

describe SqlQueryExecutor::Base do
  describe ".where" do
    let(:data) do
      [
        {id: 1, name: "US",     language: 'English'},
        {id: 2, name: "Canada", language: 'English', monarch: "The Crown of England"},
        {id: 3, name: "Mexico", language: 'Spanish'},
        {id: 4, name: "UK",     language: 'English', monarch: "The Crown of England"},
        {id: 5, name: "Brazil", founded_at: Time.parse('1500-04-22 13:34:25')}
      ]
    end

    context 'conforming collection' do
      before do
        class Model
          attr_reader :attributes

          def initialize(attributes)
            @attributes = attributes
          end

          def id
            @attributes[:id]
          end
        end

        class Collection
          def initialize(collection)
            @collection = []

            collection.each do |hash|
              @collection << Model.new(hash)
            end
          end

          def all
            @collection
          end
        end
      end

      it 'initializes with a conforming collection' do
        expect(described_class.where(Collection.new(data).all, id: 1).first.attributes).to eq (data.first)
      end
      
      context "when invalid query is passed" do
        it "raises an ArgumentError" do
          query = [{name: "John"}]

          expect { described_class.where(Collection.new(data).all, query) }.to raise_error(ArgumentError, "First element from array must be a String. eg: [\"name = ?\", \"John\"]")
        end
      end
    end

    context 'not conforming collection' do
      it 'initializes with a conforming collection' do
        expect(described_class.where(data, id: 1)).to eq([OpenStruct.new(data.first)])
      end
      
      context "when invalid query is passed" do
        it "raises an ArgumentError" do
          query = [{name: "John"}]

          expect { described_class.where(data, query) }.to raise_error(ArgumentError, "First element from array must be a String. eg: [\"name = ?\", \"John\"]")
        end
      end
    end
  end

  context 'selector' do
    let(:query)    { 'id > 3' }
    let(:selector) { {'id' => {'$gt' => 3}} }

    it 'converts query' do
      expect(described_class.new(query).selector).to eq selector
    end
  end

  context 'to_sql' do
    it 'converts selector' do
      query = "name = 'Brazil'"
      selector = {name: 'Brazil'}

      expect(described_class.new(selector).to_sql).to eq query
    end

    it 'if is a string returns itself' do
      wrong_query = "id is not 'null'"

      expect(described_class.new(wrong_query).to_sql).to eq wrong_query
    end
  end
end
