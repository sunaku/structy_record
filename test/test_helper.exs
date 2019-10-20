ExUnit.start()

defmodule StructyRecordTest.DefmoduleTestHelper do
  defmacro describe_defmodule(description, fields, do_block) do
    quote do
      defmodule unquote(Module.concat([__MODULE__, description])) do
        defmodule Setup do
          require StructyRecord

          StructyRecord.defmodule Record, unquote(fields) do
            defmacro macro(arg) do
              quote do
                unquote(arg)
              end
            end

            def function(arg), do: arg
          end
        end

        defmodule Test do
          use ExUnit.Case, async: true

          require Setup.Record

          describe "defmodule()" do
            test "injects do..end block into module definition" do
              assert Setup.Record.macro(:ok) == :ok
              assert Setup.Record.function(:ok) == :ok
            end
          end

          require Setup.Record.StructyRecord

          unquote(do_block)
        end
      end
    end
  end
end
