ExUnit.start()

defmodule StructyRecordTest.DefmoduleTestHelper do
  defmacro describe_defmodule(description, fields, do_block) do
    quote do
      defmodule unquote(Module.concat([__MODULE__, description])) do
        defmodule Setup do
          require StructyRecord

          StructyRecord.defmodule Record, unquote(fields) do
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

          unquote(do_block)
        end
      end
    end
  end
end
