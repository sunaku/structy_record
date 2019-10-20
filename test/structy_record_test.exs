defmodule StructyRecordTest do
  use ExUnit.Case
  doctest StructyRecord

  import StructyRecordTest.DefmoduleTestHelper

  describe_defmodule "no fields in record", [] do
    describe "record/0" do
      test "to create a new record with default values for all fields" do
        assert Setup.Record.record() == Setup.Record.StructyRecord.record()
      end
    end
  end

  describe_defmodule "one field in record", [:one] do
    describe "record/1" do
      test "to create a new record with the given fields and values" do
        assert Setup.Record.record(one: 1) ==
                 Setup.Record.StructyRecord.record(one: 1)
      end

      test "to get the zero-based index of the given field in a record" do
        assert Setup.Record.record(:one) ==
                 Setup.Record.StructyRecord.record(:one)
      end

      test "to convert the given record to a keyword list" do
        record = Setup.Record.record()

        assert Setup.Record.record(record) ==
                 Setup.Record.StructyRecord.record(record)
      end
    end
  end
end
