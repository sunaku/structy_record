defmodule StructyRecord do
  @moduledoc """
  Documentation for StructyRecord.
  """

  defmacro defmodule(alias = {:__aliases__, _line, [name]}, fields, do_block) do
    target_module = Module.concat([__CALLER__.module, name])
    record_module = Module.concat([target_module, :StructyRecord])

    record_macros = macros(record_module)
    field_getters = fields |> Enum.map(&getter(&1, record_module))
    field_setters = fields |> Enum.map(&setter(&1, record_module))

    quote do
      defmodule unquote(record_module) do
        require Record
        Record.defrecord(:record, unquote(alias), unquote(fields))
      end

      defmodule unquote(alias) do
        unquote(record_macros)
        unquote(field_getters)
        unquote(field_setters)
        unquote(do_block)
      end
    end
  end

  defp macros(record_module) do
    quote do
      require unquote(record_module)

      defmacro record(args \\ []) do
        quote do
          call(unquote(args))
        end
        |> unquote(delegation(record_module))
      end

      defmacro record(record, args) do
        quote do
          call(unquote(record), unquote(args))
        end
        |> unquote(delegation(record_module))
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
          {call, meta, _args = [record, :field]} ->
            args = [record, unquote(field)]
            {call, meta, args}
        end
        |> unquote(delegation(record_module))
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
          {call, meta, _args = [record, value]} ->
            args = [record, [{unquote(field), value}]]
            {call, meta, args}
        end
        |> unquote(delegation(record_module))
      end
    end
  end

  defp delegation(record_module) do
    delegated_call =
      {
        _call = :.,
        _meta = [],
        _args = [record_module, :record]
      }
      |> Macro.escape()

    quote do
      case do
        {_call, meta, args} -> {unquote(delegated_call), meta, args}
      end
    end
  end
end
