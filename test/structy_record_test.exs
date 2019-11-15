defmodule StructyRecordTest do
  use ExUnit.Case
  doctest StructyRecord

  describe "defrecord/2" do
    test "the do..end block is optional" do
      StructyRecord.defrecord(OptionalDoBlockTest, [])
    end
  end

  import TestHelper, only: :macros

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

    describe "to_list/1" do
      test "to convert a record into a Keyword list" do
        record = Setup.Record.record()
        assert Setup.Record.to_list(record) == []
      end

      test "disambiguate record/2 which creates a record from Keyword list" do
        assert_raise ArgumentError, "expected a #{inspect(Setup.Record)} record, got []", fn ->
          Setup.Record.to_list([])
        end
      end
    end

    describe "inspect/2" do
      test "to pretty-print a record with its field names and values" do
        record = Setup.Record.record()
        module = inspect(Setup.Record)
        assert Setup.Record.inspect(record) == "#{module}.record()"
        assert Setup.Record.inspect(record, label: "foo") == "foo: #{module}.record()"
      end
    end
  end

  describe_defrecord "one field in record", [:one] do
    describe "from_list/1" do
      test "to create a new record at runtime with the given fields and values" do
        test_create_runtime_record(Keyword.new())
        test_create_runtime_record(Map.new())
      end

      defp test_create_runtime_record(container) do
        contents = [one: 1] |> Enum.into(container)
        assert Setup.Record.from_list(contents) == Setup.Record.record(one: 1)
        assert Setup.Record.from_list([]) == Setup.Record.record()
      end
    end

    describe "record!/2" do
      test "to update an existing record with the given fields and values" do
        test_update_runtime_record(Keyword.new())
        test_update_runtime_record(Map.new())
      end

      defp test_update_runtime_record(container) do
        record = Setup.Record.record()
        assert record |> Setup.Record.one() == nil

        updates = [one: 1] |> Enum.into(container)
        runtime_record = record |> Setup.Record.record!(updates)
        assert runtime_record |> Setup.Record.one() == 1
      end
    end

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

    describe "fetch/2" do
      test "to access a given field in a given record" do
        record = Setup.Record.record()
        assert record |> Setup.Record.fetch(:one) == nil
      end

      test "disambiguate update/2 which delegates to record/2 with Keyword list" do
        record = Setup.Record.record()

        assert_raise ArgumentError, "expected an atom, got []", fn ->
          record |> Setup.Record.fetch([])
        end
      end
    end

    describe "update/2" do
      test "to update an existing record with the given fields and values" do
        record = Setup.Record.record()
        updated_record = record |> Setup.Record.update(one: 1)
        assert updated_record |> Setup.Record.fetch(:one) == 1
      end

      test "disambiguate fetch/2 which delegates to record/2 with field atom" do
        record = Setup.Record.record()

        assert_raise ArgumentError, "expected a Keyword list, got :one", fn ->
          record |> Setup.Record.update(:one)
        end
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

    describe "index/1" do
      test "to get the zero-based index of the given field in a record" do
        assert Setup.Record.index(:one) == Setup.Record.StructyRecord.record(:one)
      end
    end

    describe "keypos/1" do
      test "to get the 1-based index of the given field in a record" do
        assert Setup.Record.keypos(:one) ==
                 1 + Setup.Record.StructyRecord.record(:one)
      end
    end

    describe "inspect/2" do
      test "to pretty-print a record with its field names and values" do
        record = Setup.Record.record(one: 1)
        assert Setup.Record.inspect(record) == "#{inspect(Setup.Record)}.record(one: 1)"
      end
    end
  end

  describe_defrecord "field with default value", one: 1 do
    describe "from_list/1" do
      test "uses default field value when not specified in new contents" do
        contents = [two: 2]
        runtime_record = Setup.Record.from_list(contents)
        assert runtime_record |> Setup.Record.one() == 1
      end
    end

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

    describe "to_list/1" do
      test "to convert a record into a Keyword list" do
        record = Setup.Record.record()
        assert Setup.Record.to_list(record) == [one: 1]
      end
    end
  end

  describe_defrecord "field name conflicts with macro", [
    :record,
    :record!,
    :record?,
    :fetch,
    :update,
    :index,
    :keypos,
    :inspect,
    :to_list,
    :from_list
  ] do
    describe "${field}/1" do
      test "to access a specific field in a given record" do
        record = Setup.Record.record()
        assert Setup.Record.record(record) == Setup.Record.StructyRecord.record(record)
        assert Setup.Record.record!(record, []) == Setup.Record.StructyRecord.record(record, [])
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
      warnings = Setup.warnings()

      record = Setup.Record.record()
      fields = record |> Setup.Record.to_list() |> Keyword.keys()

      for field <- fields do
        assert warnings =~ ~r/warning: .+Field name #{inspect(field)} conflicts with .+/,
               "should warn about #{inspect(field)} field name conflict"
      end
    end
  end
end
