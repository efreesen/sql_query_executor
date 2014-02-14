require 'spec_helper'

require 'sql_query_executor'

describe SqlQueryExecutor, "Base" do
  before do
    @data = []

    @data << {id: 1, name: "US",     language: 'English'}
    @data << {id: 2, name: "Canada", language: 'English', monarch: "The Crown of England"}
    @data << {id: 3, name: "Mexico", language: 'Spanish'}
    @data << {id: 4, name: "UK",     language: 'English', monarch: "The Crown of England"}
    @data << {id: 5, name: "Brazil", founded_at: Time.parse('1500-04-22 13:34:25')}
  end

  subject { SqlQueryExecutor::Base.new(@data) }

  describe ".where" do
    describe "=" do
      context "when attribute is string" do
        it "matches a record" do
          record = subject.where("name = 'US'")
          record.size.should == 1
          record.first.id.should == 1
          record.first.name.should == 'US'
        end

        it "doesn't match any record" do
          record = subject.where("name = 'Argentina'")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is integer" do
        it "matches a record" do
          record = subject.where("id = 1")
          record.count.should == 1
          record.first.id.should == 1
          record.first.name.should == 'US'
        end

        it "doesn't match any record" do
          record = subject.where("id = 43")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is datetime" do
        it "matches a record" do
          record = subject.where("founded_at = ?", Time.parse('1500-04-22 13:34:25'))
          record.count.should == 1
          record.first.id.should == 5
          record.first.name.should == 'Brazil'
        end

        it "doesn't match any record" do
          record = subject.where("id = ?", Time.parse('1500-09-07 13:34:25'))
          record.count.should == 0
          record.should == []
        end
      end
    end

    describe ">" do
      context "when attribute is a string" do
        it "matches a record" do
          records = subject.where("name > 'T'")
          records.count.should == 2
          records.first.id.should == 1

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[0], @data[3]]
        end

        it "doesn't match any record" do
          record = subject.where("name > 'Z'")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is integer" do
        it "matches a record" do
          records = subject.where("id > 3")
          records.count.should == 2
          records.first.id.should == 4

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[3], @data[4]]
        end

        it "doesn't match any record" do
          record = subject.where("id > 5")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is datetime" do
        it "matches a record" do
          record = subject.where("founded_at > ?", Time.parse('1500-04-20 13:34:25'))
          record.count.should == 1
          record.first.id.should == 5
          record.first.name.should == 'Brazil'
        end

        it "doesn't match any record" do
          record = subject.where("founded_at > ?", Time.parse('1500-04-23 13:34:25'))
          record.count.should == 0
          record.should == []
        end
      end
    end

    describe ">=" do
      context "when attribute is a string" do
        it "matches a record" do
          records = subject.where("name >= 'U'")
          records.count.should == 2
          records.first.id.should == 1

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[0], @data[3]]
        end

        it "doesn't match any record" do
          record = subject.where("name >= 'Z'")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is integer" do
        it "matches a record" do
          records = subject.where("id >= 4")
          records.count.should == 2
          records.first.id.should == 4

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[3], @data[4]]
        end

        it "doesn't match any record" do
          record = subject.where("id >= 6")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is datetime" do
        it "matches a record" do
          record = subject.where("founded_at >= ?", Time.parse('1500-04-22 13:34:25'))
          record.count.should == 1
          record.first.id.should == 5
          record.first.name.should == 'Brazil'
        end

        it "doesn't match any record" do
          record = subject.where("founded_at >= ?", Time.parse('1500-04-23 13:34:25'))
          record.count.should == 0
          record.should == []
        end
      end
    end

    describe "<" do
      context "when attribute is a string" do
        it "matches a record" do
          records = subject.where("name < 'C'")
          records.count.should == 1
          records.first.id.should == 5

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[4]]
        end

        it "doesn't match any record" do
          record = subject.where("name < 'B'")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is integer" do
        it "matches a record" do
          records = subject.where("id < 3")
          records.count.should == 2
          records.first.id.should == 1

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[0], @data[1]]
        end

        it "doesn't match any record" do
          record = subject.where("id < 1")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is datetime" do
        it "matches a record" do
          record = subject.where("founded_at < ?", Time.parse('1500-04-22 13:34:26'))
          record.count.should == 1
          record.first.id.should == 5
          record.first.name.should == 'Brazil'
        end

        it "doesn't match any record" do
          record = subject.where("founded_at < ?", Time.parse('1500-04-22 13:34:25'))
          record.count.should == 0
          record.should == []
        end
      end
    end

    describe "<=" do
      context "when attribute is a string" do
        it "matches a record" do
          records = subject.where("name <= 'Brb'")
          records.count.should == 1
          records.first.id.should == 5

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[4]]
        end

        it "doesn't match any record" do
          record = subject.where("name <= 'A'")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is integer" do
        it "matches a record" do
          records = subject.where("id <= 2")
          records.count.should == 2
          records.first.id.should == 1

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[0], @data[1]]
        end

        it "doesn't match any record" do
          record = subject.where("id <= 0")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is datetime" do
        it "matches a record" do
          record = subject.where("founded_at <= ?", Time.parse('1500-04-22 13:34:25'))
          record.count.should == 1
          record.first.id.should == 5
          record.first.name.should == 'Brazil'
        end

        it "doesn't match any record" do
          record = subject.where("founded_at <= ?", Time.parse('1500-04-22 13:34:24'))
          record.count.should == 0
          record.should == []
        end
      end
    end

    describe "between" do
      context "when attribute is a string" do
        it "matches a record" do
          records = subject.where("name between 'A' and 'C'")
          records.count.should == 1
          records.first.id.should == 5

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[4]]
        end

        it "doesn't match any record" do
          record = subject.where("name between 'K' and 'M'")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is integer" do
        it "matches a record" do
          records = subject.where("id between 1 and 2")
          records.count.should == 2
          records.first.id.should == 1

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[0], @data[1]]
        end

        it "doesn't match any record" do
          record = subject.where("id between 6 and 10")
          record.count.should == 0
          record.should == []
        end
      end

      context "when attribute is datetime" do
        it "matches a record" do
          record = subject.where("founded_at between ? and ?", Time.parse('1500-04-22 13:34:24'), Time.parse('1500-04-22 13:34:26'))
          record.count.should == 1
          record.first.id.should == 5
          record.first.name.should == 'Brazil'
        end

        it "doesn't match any record" do
          record = subject.where("founded_at between ? and ?", Time.parse('1500-04-22 13:34:26'), Time.parse('1500-09-22 13:34:25'))
          record.count.should == 0
          record.should == []
        end
      end
    end

    describe "is" do
      it "attribute is condition" do
        records = subject.where("founded_at is null")
        records.count.should == 4
        records.first.id.should == 1

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[0], @data[1], @data[2], @data[3]]
      end

      it "attribute is not condition" do
        id = @data.last[:id]
        records = subject.where("founded_at is not null")
        records.count.should == 1
        records.first.id.should == id

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[id-1]]
      end
    end

    describe "and" do
      it "attribute and condition" do
        records = subject.where("language = 'English' and monarch = 'The Crown of England'")
        records.count.should == 2
        records.first.id.should == 2

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[1], @data[3]]
      end

      it "integer attribute and condition" do
        records = subject.where("id = 2 and language = 'English'")
        records.count.should == 1
        records.first.id.should == 2

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[1]]
      end
    end

    describe "or" do
      it "attribute or condition" do
        records = subject.where("language = 'English' or language = 'Spanish'")
        records.count.should == 4
        records.first.id.should == 1

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[0], @data[1], @data[2], @data[3]]
      end

      context "nested queries" do
        it "respects priority" do
          records = subject.where("(language = 'English' and name = 'US') or (language is null)")
          records.count.should == 2
          records.first.id.should == 1

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[0], @data[4]]
        end

        it "respects priority" do
          records = subject.where("(language is null) or (language = 'English' and name = 'US')")
          records.count.should == 2
          records.first.id.should == 1

          records.map! do |record|
            record.to_h
          end

          records.should == [@data[0], @data[4]]
        end
      end
    end

    describe "in" do
      it "attribute in condition" do
        records = subject.where("language in ('English', 'Spanish')")
        records.count.should == 4
        records.first.id.should == 1

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[0], @data[1], @data[2], @data[3]]
      end

      xit "attribute not in condition" do
        records = subject.where("language not in ('English', 'Spanish')")
        records.count.should == 1
        records.first.id.should == 5

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[4]]
      end
    end

    describe "not" do
      xit "attribute not condition" do
        records = subject.where("not language = 'English'")
        records.count.should == 1
        records.first.id.should == 5

        records.map! do |record|
          record.to_h
        end

        records.should == [@data[4]]
      end
    end
  end
end
