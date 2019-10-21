defmodule StructyRecord do
  @moduledoc """
  Documentation for StructyRecord.
  """

  defmacro defmodule(alias = {:__aliases__, _line, [name]}, fields, do_block) do
    target_module = Module.concat([__CALLER__.module, name])
    record_module = Module.concat([target_module, :StructyRecord])

    using_handler = using()
    record_macros = macros(record_module)
    field_names = field_names(fields)
    field_getters = field_names |> Enum.map(&getter/1)
    field_setters = field_names |> Enum.map(&setter/1)

    quote do
      defmodule unquote(record_module) do
        require Record
        Record.defrecord(:record, unquote(alias), unquote(fields))
      end

      defmodule unquote(alias) do
        unquote(using_handler)
        unquote(record_macros)
        unquote(field_getters)
        unquote(field_setters)
        unquote(do_block)
      end
    end
  end

  defp field_names(fields) do
    if Keyword.keyword?(fields) do
      Keyword.keys(fields)
    else
      fields
    end
  end

  defp using do
    quote do
      defmacro __using__(_opts) do
        quote do
          require unquote(__MODULE__).StructyRecord
          require unquote(__MODULE__)
        end
      end
    end
  end

  defp macros(record_module) do
    quote do
      require unquote(record_module)

      defmacro record(args \\ []) do
        quote do
          unquote(__MODULE__).StructyRecord.record(unquote(args))
        end
      end

      defmacro record(record, args) do
        quote do
          unquote(__MODULE__).StructyRecord.record(unquote(record), unquote(args))
        end
      end
    end
  end

  defp getter(field) do
    quote do
      defmacro unquote(field)(record) do
        quote do
          unquote(__MODULE__).StructyRecord.record(unquote(record), :field)
        end
        |> case do
          {call, meta, _args = [record, :field]} ->
            args = [record, unquote(field)]
            {call, meta, args}
        end
      end
    end
  end

  defp setter(field) do
    quote do
      defmacro unquote(field)(record, value) do
        quote do
          unquote(__MODULE__).StructyRecord.record(unquote(record), unquote(value))
        end
        |> case do
          {call, meta, _args = [record, value]} ->
            args = [record, [{unquote(field), value}]]
            {call, meta, args}
        end
      end
    end
  end
end
