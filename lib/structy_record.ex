defmodule StructyRecord do
  @moduledoc """
  Documentation for StructyRecord.
  """

  defmacro defmodule(alias = {:__aliases__, _line, [name]}, fields, do_block) do
    target_module = Module.concat([__CALLER__.module, name])
    record_module = Module.concat([target_module, :StructyRecord])

    quote do
      defmodule unquote(record_module) do
        require Record
        Record.defrecord(:record, unquote(alias), unquote(fields))
      end

      defmodule unquote(alias) do
        require unquote(record_module)

        defmacro record(args \\ []) do
          quote do
            __this_is_overwritten_by_put_elem_below__(unquote(args))
          end
          |> put_elem(0, {:., [], [unquote(record_module), :record]})
        end

        unquote(do_block)
      end
    end
  end
end
