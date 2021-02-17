ExUnit.start()

defmodule TestHelper do
  require StructyRecord

  StructyRecord.defrecord(NoFields, [])
  StructyRecord.defrecord(OneField, [:one])
  StructyRecord.defrecord(OneFieldWithDefaultValue, one: 1)
  StructyRecord.defrecord(TwoFields, [:one, :two])

  StructyRecord.defrecord NoFieldsWithCustomDoBlock, [] do
    defmacro macro(arg) do
      quote do
        unquote(arg)
      end
    end

    def function(arg), do: arg

    def function_using_macros, do: function_using_macros(record())
    def function_using_macros(r = record()), do: r
  end
end
