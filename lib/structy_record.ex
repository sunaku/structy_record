defmodule StructyRecord do
  @moduledoc """
  Documentation for StructyRecord.
  """

  @reserved_names [:record, :keypos]

  defmacro defmodule(alias = {:__aliases__, _line, [name]}, fields, do_block) do
    target_module = Module.concat([__CALLER__.module, name])
    record_module = Module.concat([target_module, :StructyRecord])

    quote do
      defmodule unquote(record_module) do
        require Record
        Record.defrecord(:record, unquote(alias), unquote(fields))
      end

      defmodule unquote(alias) do
        unquote(macros(record_module, field_names(fields) -- @reserved_names))
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

  defp macros(record_module, field_names) do
    using_handler = using_macro()
    record_macros = record_macros()
    keypos_macros = keypos_macros()
    field_getters = field_names |> Enum.map(&getter_macro/1)
    field_setters = field_names |> Enum.map(&setter_macro/1)

    quote do
      require unquote(record_module)
      unquote(using_handler)
      unquote(record_macros)
      unquote(keypos_macros)
      unquote(field_getters)
      unquote(field_setters)
    end
  end

  defp using_macro do
    quote do
      defmacro __using__(_opts) do
        quote do
          require unquote(__MODULE__).StructyRecord
          require unquote(__MODULE__)
        end
      end
    end
  end

  defp record_macros() do
    quote do
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

  defp keypos_macros() do
    quote do
      defmacro keypos(args) do
        quote do
          1 + unquote(__MODULE__).StructyRecord.record(unquote(args))
        end
      end
    end
  end

  defp getter_macro(field) do
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

  defp setter_macro(field) do
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
