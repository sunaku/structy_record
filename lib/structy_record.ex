defmodule StructyRecord do
  @moduledoc """
  Documentation for StructyRecord.
  """

  defmacro defmodule(alias = {:__aliases__, _line, [name]}, fields, do_block) do
    target_module = Module.concat([__CALLER__.module, name])
    record_module = Module.concat([target_module, :StructyRecord])

    field_getters = fields |> Enum.map(&getter(&1, record_module))
    field_setters = fields |> Enum.map(&setter(&1, record_module))

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

        defmacro record(record, args) do
          quote do
            __this_is_overwritten_by_put_elem_below__(
              unquote(record),
              unquote(args)
            )
          end
          |> put_elem(0, {:., [], [unquote(record_module), :record]})
        end

        unquote(field_getters)
        unquote(field_setters)

        unquote(do_block)
      end
    end
  end

  defp getter(field, record_module) do
    quote do
      defmacro unquote(field)(record) do
        quote do
          call(unquote(record), :field)
        end
        |> case do
          {_call, meta, _args = [record, :field]} ->
            call = {:., [], [unquote(record_module), :record]}
            args = [record, unquote(field)]
            {call, meta, args}
        end
      end
    end
  end

  defp setter(field, record_module) do
    quote do
      defmacro unquote(field)(record, value) do
        quote do
          call(unquote(record), unquote(value))
        end
        |> case do
          {_call, meta, _args = [record, value]} ->
            call = {:., [], [unquote(record_module), :record]}
            args = [record, [{unquote(field), value}]]
            {call, meta, args}
        end
      end
    end
  end
end
