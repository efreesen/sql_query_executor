require 'spec_helper'
require 'sql_query_executor/query/sentence'

describe SqlQueryExecutor::Query::Sentence do
  context "when single query" do
    context "and Default Operator" do
      let(:query) { "name = \"US\"" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"name"=>"US"})
        end
      end

      context 'logic' do
        context 'and is not a Hash' do
          it 'returns selector' do
            expect(subject.logic).to eq("name == 'US'")
          end
        end

        context 'and is a Hash' do
          it 'returns selector' do
            expect(subject.logic(true)).to eq("self[:name] == 'US'")
          end
        end
      end
    end

    context "and Between Operator" do
      let(:query) { "created_at between '2013-12-31' and '2014-01-12'" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"created_at"=>{"$gte"=>Date.new(2013,12,31), "$lte"=>Date.new(2014,01,12)}})
        end
      end

      context 'logic' do
        context 'and is not a hash' do
          it 'returns logic' do
            expect(subject.logic).to eq("created_at >= Date.new(2013, 12, 31) && created_at <= Date.new(2014, 1, 12)")
          end
        end

        context 'and is a hash' do
          it 'returns logic' do
            expect(subject.logic(true)).to eq("self[:created_at] >= Date.new(2013, 12, 31) && self[:created_at] <= Date.new(2014, 1, 12)")
          end
        end
      end
    end

    context "and Is Operator" do
      let(:query) { "language is null" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"language"=>nil})
        end
      end

      context 'logic' do
        context 'and is not a Hash' do
          it 'returns logic' do
            expect(subject.logic).to eq("language == nil")
          end
        end

        context 'and is a Hash' do
          it 'returns logic' do
            expect(subject.logic(true)).to eq("self[:language] == nil")
          end
        end
      end
    end

    context "and In Operator" do
      let(:query) { "language in ('English','Spanish')" }
      subject { described_class.new(query) }

      context 'query' do
        it 'returns the query' do
          expect(subject.query).to eq query
        end
      end

      context 'selector' do
        it 'returns selector' do
          expect(subject.selector).to eq({"language"=>{"$in"=>["English", "Spanish"]}})
        end
      end

      context 'logic' do
        context 'and is not a Hash' do
          it 'returns logic' do
            expect(subject.logic).to eq("['English', 'Spanish'].include?(language)")
          end
        end

        context 'and is a Hash' do
          it 'returns logic' do
            expect(subject.logic(true)).to eq("['English', 'Spanish'].include?(self[:language])")
          end
        end
      end
    end
  end
end
