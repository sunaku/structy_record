defmodule StructyRecordTest do
  use ExUnit.Case
  doctest StructyRecord

  defmodule Describe__defmodule_with_zero_record_fields do
    defmodule Setup do
      require StructyRecord

      StructyRecord.defmodule Record, [] do
        def my_function, do: :ok
      end
    end

    defmodule Test do
      use ExUnit.Case, async: true

      describe "defmodule()" do
        test "injects do..end block into module definition" do
          assert Setup.Record.my_function() == :ok
        end
      end

      require Setup.Record
      require Setup.Record.StructyRecord

      describe "record/0" do
        test "to create a new record with default values for all fields" do
          assert Setup.Record.record() == Setup.Record.StructyRecord.record()
        end
      end
    end
  end

  defmodule Describe__defmodule_with_single_record_field do
    defmodule Setup do
      require StructyRecord

      StructyRecord.defmodule Record, [:foo] do
        def my_function, do: :ok
      end
    end

    defmodule Test do
      use ExUnit.Case, async: true

      describe "defmodule()" do
        test "injects do..end block into module definition" do
          assert Setup.Record.my_function() == :ok
        end
      end

      require Setup.Record
      require Setup.Record.StructyRecord

      describe "record/1" do
        test "to create a new record with the given fields and values" do
          assert Setup.Record.record(foo: 123) ==
                   Setup.Record.StructyRecord.record(foo: 123)
        end

        test "to get the zero-based index of the given field in a record" do
          assert Setup.Record.record(:foo) ==
                   Setup.Record.StructyRecord.record(:foo)
        end

        test "to convert the given record to a keyword list" do
          record = Setup.Record.record()

          assert Setup.Record.record(record) ==
                   Setup.Record.StructyRecord.record(record)
        end
      end
    end
  end
end
