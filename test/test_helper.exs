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

            def function_using_macros(r = record()), do: r
          end
        end

        defmodule Test do
          use ExUnit.Case, async: true
          use Setup.Record

          describe "defmodule()" do
            test "injects do..end block into module definition" do
              assert Setup.Record.macro(:ok) == :ok
              assert Setup.Record.function(:ok) == :ok
            end

            test "record() macros can be used in do..end block" do
              record = Setup.Record.record()
              assert record |> Setup.Record.function_using_macros() == record
            end
          end

          unquote(do_block)
        end
      end
    end
  end
end
