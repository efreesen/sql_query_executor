require 'spec_helper'

require 'sql_query_executor'
require 'sql_query_executor/base'

describe SqlQueryExecutor::Base do
  describe ".where" do
    let(:data) do
      array = [{id: 1, name: "US",     language: 'English'}]

      500.times do |i|
        array.push({id: i+2, name: "Name-#{i}", language: 'English'})
      end

      array
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
        data
        result = described_class.where(Collection.new(data).all, id: 1)

        expect(data.first).to eq (data.first)
      end
      
      context "when invalid query is passed" do
        it "raises an ArgumentError" do
          query = [{name: "John"}]

          expect { described_class.where(Collection.new(data).all, query) }.to raise_error(ArgumentError, "First element from array must be a String. eg: [\"name = ?\", \"John\"]")
        end
      end
    end

    context 'non conforming collection' do
      it 'initializes with a non conforming collection' do
        data
        result = described_class.where(data, id: 1)

        expect(described_class.where(data, id: 1)).to eq([data.first])
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
