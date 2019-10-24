defmodule StructyRecordTest do
  use ExUnit.Case
  doctest StructyRecord

  describe "defrecord/2" do
    test "the do..end block is optional" do
      StructyRecord.defrecord(OptionalDoBlockTest, [])
    end
  end

  import StructyRecordTest.DefrecordTestHelper

  describe_defrecord "no fields in record", [] do
    describe "record/0" do
      test "to create a new record with default values for all fields" do
        assert Setup.Record.record() |> elem(0) == Setup.Record
        assert Setup.Record.record() == Setup.Record.StructyRecord.record()
      end
    end

    describe "record?/1" do
      test "checks if argument strictly matches the shape of this record" do
        assert Setup.Record.record() |> Setup.Record.record?()
        assert Setup.Record.StructyRecord.record() |> Setup.Record.record?()

        refute {Setup.Record, :any_extra_field_is_also_checked_by_this_macro}
               |> Setup.Record.record?()
      end
    end

    describe "is_record/1" do
      test "checks if argument loosely matches the shape of this record" do
        assert_is_record(Setup.Record.record())
        assert_is_record(Setup.Record.StructyRecord.record())
        assert_is_record({Setup.Record, :extra_field_is_NOT_checked_by_guard})
      end

      defp assert_is_record(record) do
        case record do
          ^record when Setup.Record.is_record(record) -> :ok
          other -> flunk("didn't match #{inspect(other)}")
        end
      end
    end
  end

  describe_defrecord "one field in record", [:one] do
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

    describe "record/2" do
      test "to access a given field in a given record" do
        record = Setup.Record.record()
        assert record |> Setup.Record.record(:one) == nil
      end

      test "to update an existing record with the given fields and values" do
        record = Setup.Record.record()
        updated_record = record |> Setup.Record.record(one: 1)
        assert updated_record |> Setup.Record.record(:one) == 1
      end
    end

    describe "${field}/1" do
      test "to access a specific field in a given record" do
        record = Setup.Record.record()
        assert record |> Setup.Record.one() == nil
      end
    end

    describe "${field}/2" do
      test "to assign a specific field in a given record" do
        record = Setup.Record.record()
        assert record |> Setup.Record.one(1) == Setup.Record.record(one: 1)
      end
    end

    describe "keypos/1" do
      test "to get the 1-based index of the given field in a record" do
        assert Setup.Record.keypos(:one) ==
                 1 + Setup.Record.StructyRecord.record(:one)
      end
    end
  end

  describe_defrecord "field with default value", one: 1 do
    describe "record/2" do
      test "to access a given field in a given record" do
        record = Setup.Record.record()
        assert record |> Setup.Record.record(:one) == 1
      end
    end

    describe "${field}/1" do
      test "to access a specific field in a given record" do
        record = Setup.Record.record()
        assert record |> Setup.Record.one() == 1
      end
    end
  end

  describe_defrecord "field name conflicts with macro", [:record, :record?, :keypos] do
    describe "${field}/1" do
      test "to access a specific field in a given record" do
        record = Setup.Record.record()
        assert Setup.Record.record(record) == Setup.Record.StructyRecord.record(record)
        assert Setup.Record.record?(record) == match?(Setup.Record.StructyRecord.record(), record)
      end
    end

    describe "keypos/1" do
      test "to get the 1-based index of the given field in a record" do
        assert Setup.Record.keypos(:keypos) ==
                 1 + Setup.Record.StructyRecord.record(:keypos)
      end
    end

    test "warns about field names that conflict with reserved names" do
      import ExUnit.CaptureIO

      warnings =
        capture_io(:stderr, fn ->
          StructyRecord.defrecord(ReservedFieldsTest, [:record, :record?, :keypos])
        end)

      assert warnings =~ ~r/warning: .+Field name :record conflicts with .+/
      assert warnings =~ ~r/warning: .+Field name :record\? conflicts with .+/
      assert warnings =~ ~r/warning: .+Field name :keypos conflicts with .+/
    end
  end
end
