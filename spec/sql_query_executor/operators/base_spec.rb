require 'spec_helper'
require 'sql_query_executor'

describe SqlQueryExecutor::Operators::Base do
  describe "#selector" do
    context 'simple query' do
      subject { described_class.new("name = 'name'") }

      it 'converts query' do
        expect(subject.selector).to eq({'name' => 'name'})
      end
    end
    
    context 'query with operator' do
      subject { described_class.new("name < 'name'") }

      it 'ignores the operator' do
        expect(subject.selector).to eq({'name' => 'name'})
      end
    end
    
    context 'invalid query' do
      subject { described_class.new("John's name is 'John'") }

      it 'forms an invalid query' do
        expect(subject.selector).to eq({"John's$SS$name$SS$is$SS$'John'"=>"Johns name is John"})
      end
    end

    context 'integer parameter' do
      subject { described_class.new("id = 1") }

      it 'forms an invalid query' do
        expect(subject.selector).to eq({"id"=>1})
      end
    end

    context 'number as string parameter' do
      subject { described_class.new("id = '1'") }

      it 'forms an invalid query' do
        expect(subject.selector).to eq({"id"=>1})
      end
    end

    context 'date parameter' do
      context 'when a valid date is passed' do
        subject { described_class.new("date = '2014-01-01'") }

        it 'forms an invalid query' do
          expect(subject.selector).to eq({"date"=>Date.new(2014,01,01)})
        end
      end

      context 'when an invalid date is passed' do
        subject { described_class.new("date = 'This not date'") }

        it 'forms an invalid query' do
          expect(subject.selector).to eq({"date"=>'This not date'})
        end
      end
    end

    context 'time parameter' do
      context 'when a valid time is passed' do
        subject { described_class.new("time = '2014-01-01 03:02:01 +0300'") }

        it 'forms an invalid query' do
          expect(subject.selector).to eq({"time"=>Time.new(2014,01,01,03,02,01,'+03:00')})
        end
      end

      context 'when an invalid time is passed' do
        subject { described_class.new("time = 'This-is-not a:valid:time aye'") }

        it 'forms an invalid query' do
          expect(subject.selector).to eq({"time"=>'This-is-not a:valid:time aye'})
        end
      end
    end
  end

  describe "#logic" do
    context 'is not a hash' do
      context 'simple query' do
        subject { described_class.new("name = 'name'") }

        it 'converts query' do
          expect(subject.logic).to eq("name == 'name'")
        end
      end
      
      context 'query with operator' do
        subject { described_class.new("name < 'name'") }

        it 'keeps the operator' do
          expect(subject.logic).to eq("name < 'name'")
        end
      end
      
      context 'invalid query' do
        subject { described_class.new("John's name is 'John'") }

        it 'forms an invalid query' do
          expect(subject.logic).to eq("John's$SS$name$SS$is$SS$'John'  'Johns name is John'")
        end
      end

      context 'integer parameter' do
        subject { described_class.new("id = 1") }

        it 'forms an invalid query' do
          expect(subject.logic).to eq("id == 1")
        end
      end

    context 'number as string parameter' do
      subject { described_class.new("id = '1'") }

      it 'forms an invalid query' do
        expect(subject.logic).to eq("id == (id.is_a?(Fixnum) ? '1'.to_i : '1')")
      end
    end

      context 'date parameter' do
        context 'when a valid date is passed' do
          subject { described_class.new("date = '2014-01-01'") }

          it 'forms an invalid query' do
            expect(subject.logic).to eq("date == Date.new(2014, 1, 1)")
          end
        end

        context 'when an invalid date is passed' do
          subject { described_class.new("date = 'This not date'") }

          it 'forms an invalid query' do
            expect(subject.logic).to eq("date == 'This not date'")
          end
        end
      end

      context 'time parameter' do
        context 'when a valid time is passed' do
          subject { described_class.new("time = '2014-01-01 03:02:01 +0300'") }

          it 'forms an invalid query' do
            expect(subject.logic).to eq("time == Time.new(2014,01,01,03,02,01,'+03:00')")
          end
        end

        context 'when an invalid time is passed' do
          subject { described_class.new("time = 'This-is-not a:valid:time aye'") }

          it 'forms an invalid query' do
            expect(subject.logic).to eq("time == 'This-is-not a:valid:time aye'")
          end
        end
      end
    end

    context 'is a hash' do
      context 'simple query' do
        subject { described_class.new("name = 'name'") }

        it 'converts query' do
          expect(subject.logic(true)).to eq("self[:name] == 'name'")
        end
      end
      
      context 'query with operator' do
        subject { described_class.new("name < 'name'") }

        it 'keeps the operator' do
          expect(subject.logic(true)).to eq("self[:name] < 'name'")
        end
      end
      
      context 'invalid query' do
        subject { described_class.new("John's name is 'John'") }

        it 'forms an invalid query' do
          expect(subject.logic(true)).to eq("self[:John's$SS$name$SS$is$SS$'John']  'Johns name is John'")
        end
      end

      context 'integer parameter' do
        subject { described_class.new("id = 1") }

        it 'forms an invalid query' do
          expect(subject.logic(true)).to eq("self[:id] == 1")
        end
      end

      context 'date parameter' do
        context 'when a valid date is passed' do
          subject { described_class.new("date = '2014-01-01'") }

          it 'forms an invalid query' do
            expect(subject.logic(true)).to eq("self[:date] == Date.new(2014, 1, 1)")
          end
        end

        context 'when an invalid date is passed' do
          subject { described_class.new("date = 'This not date'") }

          it 'forms an invalid query' do
            expect(subject.logic(true)).to eq("self[:date] == 'This not date'")
          end
        end
      end

      context 'time parameter' do
        context 'when a valid time is passed' do
          subject { described_class.new("time = '2014-01-01 03:02:01 +0300'") }

          it 'forms an invalid query' do
            expect(subject.logic(true)).to eq("self[:time] == Time.new(2014,01,01,03,02,01,'+03:00')")
          end
        end

        context 'when an invalid time is passed' do
          subject { described_class.new("time = 'This-is-not a:valid:time aye'") }

          it 'forms an invalid query' do
            expect(subject.logic(true)).to eq("self[:time] == 'This-is-not a:valid:time aye'")
          end
        end
      end
    end
  end
end
