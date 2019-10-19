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
end
