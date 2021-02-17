alias TestHelper.NoFields
alias TestHelper.NoFieldsWithCustomDoBlock
alias TestHelper.OneField
alias TestHelper.OneFieldWithDefaultValue
alias TestHelper.TwoFields

defmodule StructyRecordTest do
  use ExUnit.Case
  doctest StructyRecord

  describe "defrecord/2" do
    test "the do..end block is optional" do
      StructyRecord.defrecord(OptionalDoBlockTest, [])
    end
  end

  describe "defrecord/3" do
    test "do_block: function" do
      assert NoFieldsWithCustomDoBlock.function(:ok) == :ok
    end

    test "do_block: macro" do
      require NoFieldsWithCustomDoBlock
      assert NoFieldsWithCustomDoBlock.macro(:ok) == :ok
    end

    test "do_block: function using record() macros" do
      require Record
      result = NoFieldsWithCustomDoBlock.function_using_macros()
      assert Record.is_record(result, NoFieldsWithCustomDoBlock)
    end
  end

  describe "index/3" do
    test "empty: field not found" do
      assert_raise ArgumentError, "record Foobar does not have the key: :field", fn ->
        StructyRecord.index(:field, Foobar, [])
      end
    end

    test "single: field is found" do
      assert StructyRecord.index(:field, Foobar, field: nil) == 1
    end

    test "double: field is found" do
      assert StructyRecord.index(:field, Foobar, other_field: nil, field: nil) == 2
    end
  end

  describe "from_list/2" do
    test "empty" do
      assert [] |> StructyRecord.from_list(Foobar) == {Foobar}
    end

    test "single" do
      assert [one: 1] |> StructyRecord.from_list(Foobar) == {Foobar, 1}
    end

    test "double" do
      assert [one: 1, two: 2] |> StructyRecord.from_list(Foobar) == {Foobar, 1, 2}
    end
  end

  describe "from_list/3" do
    test "empty" do
      assert [] |> StructyRecord.from_list(Foobar, []) == {Foobar}
    end

    test "empty contents: retain template" do
      template = [known: :default_value]
      contents = []
      assert contents |> StructyRecord.from_list(Foobar, template) == {Foobar, :default_value}
    end

    test "empty template: ignore contents" do
      template = []
      contents = [known: :content_value]
      assert contents |> StructyRecord.from_list(Foobar, template) == {Foobar}
    end

    test "intersection: overwrite template value with content value" do
      template = [known: :default_value]
      contents = [known: :content_value]
      assert contents |> StructyRecord.from_list(Foobar, template) == {Foobar, :content_value}
    end

    test "difference: ignore content values that aren't in template" do
      template = [known: :default_value]
      contents = [known: :content_value, unknown_extra_contents: nil]
      assert contents |> StructyRecord.from_list(Foobar, template) == {Foobar, :content_value}
    end
  end

  describe "inspect/3" do
    test "empty" do
      assert [] |> StructyRecord.inspect(Foobar) == "Foobar.{}"
    end

    test "single" do
      assert [one: 1] |> StructyRecord.inspect(Foobar) == "Foobar.{[one: 1]}"
    end

    test "supports Kernel.inspect/2 options" do
      assert [one: 1, two: 2] |> StructyRecord.inspect(Foobar, limit: 1) ==
               "Foobar.{[one: 1, ...]}"
    end

    test "invalid: contents must be a list" do
      assert_raise FunctionClauseError, fn ->
        StructyRecord.inspect("string", Foobar)
      end
    end
  end

  ## record_primitives

  use NoFields
  use OneField
  use OneFieldWithDefaultValue
  use TwoFields

  describe "{}/0" do
    test "to create a new record with default values for all fields" do
      require Record
      assert NoFields.{} |> elem(0) == NoFields
      assert NoFields.{} |> Record.is_record(NoFields)
      assert NoFields.{} == NoFields.StructyRecord.record()
    end
  end

  describe "{}/1" do
    test "to create a new record with the given fields and values" do
      assert OneField.{[one: 1]} == OneField.StructyRecord.record(one: 1)
    end

    test "to get the zero-based index of the given field in a record" do
      assert OneField.{:one} == OneField.StructyRecord.record(:one)
    end
  end

  describe "{{}}/1" do
    test "to convert the given record to a keyword list" do
      record = OneField.{}
      assert OneField.{{record}} == OneField.StructyRecord.record(record)
    end
  end

  describe "{{}}/2" do
    test "to access a given field in a given record" do
      record = OneField.{}
      assert OneField.{{record, :one}} == nil

      record = OneFieldWithDefaultValue.{}
      assert OneFieldWithDefaultValue.{{record, :one}} == 1
    end

    test "to update an existing record with the given fields and values" do
      record = OneField.{}
      updated_record = OneField.{{record, one: 1}}
      assert OneField.{{updated_record, :one}} == 1
    end
  end

  describe "record/0" do
    test "to create a new record with default values for all fields" do
      require Record
      assert NoFields.record() |> elem(0) == NoFields
      assert NoFields.record() |> Record.is_record(NoFields)
      assert NoFields.record() == NoFields.StructyRecord.record()
    end
  end

  describe "record/1" do
    test "to create a new record with the given fields and values" do
      assert OneField.record(one: 1) == OneField.StructyRecord.record(one: 1)
    end

    test "to get the zero-based index of the given field in a record" do
      assert OneField.record(:one) == OneField.StructyRecord.record(:one)
    end

    test "to convert the given record to a keyword list" do
      record = OneField.record()
      assert OneField.record(record) == OneField.StructyRecord.record(record)
    end
  end

  describe "record/2" do
    test "to access a given field in a given record" do
      record = OneField.{}
      assert record |> OneField.record(:one) == nil

      record = OneFieldWithDefaultValue.{}
      assert record |> OneFieldWithDefaultValue.record(:one) == 1
    end

    test "to update an existing record with the given fields and values" do
      record = OneField.{}
      updated_record = record |> OneField.record(one: 1)
      assert updated_record |> OneField.record(:one) == 1
    end
  end

  describe "is_record/1" do
    test "checks if argument _loosely_ matches the shape of this record" do
      assert NoFields.{} |> NoFields.is_record()
      assert NoFields.record() |> NoFields.is_record()
      assert NoFields.StructyRecord.record() |> NoFields.is_record()
      assert {NoFields, :extra_field_is_NOT_checked_by_guard} |> NoFields.is_record()
    end
  end

  describe "record?/1" do
    test "checks if argument _strictly_ matches the shape of this record" do
      assert NoFields.{} |> NoFields.record?()
      assert NoFields.record() |> NoFields.record?()
      assert NoFields.StructyRecord.record() |> NoFields.record?()

      refute {NoFields, :any_extra_field_is_also_checked_by_this_macro}
             |> NoFields.record?()
    end
  end

  ## elixiry_interface

  describe "index/1" do
    test "to get the zero-based index of the given field in a record" do
      assert OneField.index(:one) == OneField.StructyRecord.record(:one)
    end

    test "support runtime evaluation via StructyRecord.index() fallback" do
      runtime = :one
      assert OneField.index(runtime) == OneField.StructyRecord.record(:one)
    end
  end

  describe "keypos/1" do
    test "to get the 1-based index of the given field in a record" do
      assert OneField.keypos(:one) == 1 + OneField.StructyRecord.record(:one)
    end
  end

  describe "matchspec_head/1" do
    test "1-hot-encoding with :_ wildcards for unmentioned fields" do
      assert NoFields.matchspec_head([]) == NoFields.record()

      assert OneField.matchspec_head([]) == OneField.record(one: :_)
      assert OneField.matchspec_head(one: 1) == OneField.record(one: 1)

      assert TwoFields.matchspec_head([]) == TwoFields.record(one: :_, two: :_)
      assert TwoFields.matchspec_head(one: 1) == TwoFields.record(one: 1, two: :_)
      assert TwoFields.matchspec_head(two: 2) == TwoFields.record(one: :_, two: 2)
      assert TwoFields.matchspec_head(one: 1, two: 2) == TwoFields.record(one: 1, two: 2)
    end
  end

  describe "get/2" do
    test "to fetch the value of a given field in a given record" do
      record = OneField.{}
      assert record |> OneField.get(:one) == nil
    end
  end

  describe "put/2" do
    test "to update an existing record with the given fields and values" do
      record = OneField.{}
      updated_record = record |> OneField.put(one: 1)
      assert updated_record |> OneField.get(:one) == 1
    end
  end

  describe "from_list/1" do
    test "to create a new record at runtime with the given fields and values" do
      test_runtime_record_creation_from_container(Keyword.new())
      test_runtime_record_creation_from_container(Map.new())
    end

    defp test_runtime_record_creation_from_container(container) do
      contents = [one: 1] |> Enum.into(container)
      assert OneField.from_list(contents) == OneField.{[one: 1]}
      assert OneField.from_list([]) == OneField.{}
    end

    test "uses default field value when no value is specified in new contents" do
      contents = [two: 2]
      runtime_record = OneFieldWithDefaultValue.from_list(contents)
      assert runtime_record |> OneFieldWithDefaultValue.get_one() == 1
    end
  end

  describe "merge/2" do
    test "to assign the given fields and values inside a given record" do
      test_merge_runtime_record(Keyword.new())
      test_merge_runtime_record(Map.new())
    end

    defp test_merge_runtime_record(container) do
      record = OneField.{}
      assert record |> OneField.get_one() == nil

      contents = [one: 1] |> Enum.into(container)
      runtime_record = record |> OneField.merge(contents)
      assert runtime_record |> OneField.get_one() == 1
    end
  end

  describe "to_list/0" do
    test "to get a template of fields and default values for this record" do
      assert NoFields.to_list() == []
      assert OneField.to_list() == [one: nil]
      assert OneFieldWithDefaultValue.to_list() == [one: 1]
    end
  end

  describe "to_list/1" do
    test "to convert a record into a Keyword list" do
      record = NoFields.{}
      assert NoFields.to_list(record) == []

      record = OneFieldWithDefaultValue.{}
      assert OneFieldWithDefaultValue.to_list(record) == [one: 1]
    end
  end

  describe "inspect/2" do
    test "to pretty-print a record with its field names and values" do
      record = NoFields.{}
      module = inspect(NoFields)
      assert NoFields.inspect(record) == "#{module}.{}"

      record = OneField.{[one: 1]}
      assert OneField.inspect(record) == "#{inspect(OneField)}.{[one: 1]}"
    end
  end

  ## field_accessors

  describe "get_${field}/1" do
    test "to access a specific field in a given record" do
      record = OneField.{}
      assert record |> OneField.get_one() == nil

      record = OneFieldWithDefaultValue.{}
      assert record |> OneFieldWithDefaultValue.get_one() == 1
    end
  end

  describe "put_${field}/2" do
    test "to assign a specific field in a given record" do
      record = OneField.{}
      assert record |> OneField.put_one(1) == OneField.{[one: 1]}
    end
  end
end
