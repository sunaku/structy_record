defmodule StructyRecord do
  @moduledoc """
  Documentation for StructyRecord.
  """

  @reserved_field_names [:record, :record?, :keypos]

  defmacro defrecord(alias, fields, do_block \\ []) do
    quote do
      defmodule unquote(alias |> concat_alias([:StructyRecord])) do
        alias unquote(alias), as: Tag
        require Record
        Record.defrecord(:record, Tag, unquote(fields))
      end

      defmodule unquote(alias) do
        require __MODULE__.StructyRecord
        unquote(using_macro())
        unquote(record_macros())
        unquote(keypos_macros())
        unquote(access_macros(fields))
        unquote(do_block)
      end
    end
  end

  defp concat_alias({tag = :__aliases__, context, namespace}, appendix) do
    {tag, context, namespace ++ appendix}
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

      defmacro record?(record) do
        quote do
          match?(unquote(__MODULE__).StructyRecord.record(), unquote(record))
        end
      end

      require Record
      defguard is_record(record) when Record.is_record(record, __MODULE__)
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

  defp access_macros(fields) do
    {reserved_fields, allowed_fields} = reserved_vs_allowed_fields(fields)
    warnings = reserved_fields |> Enum.map(&reserved_field_warning/1)
    getters = allowed_fields |> Enum.map(&getter_macro/1)
    setters = allowed_fields |> Enum.map(&setter_macro/1)

    quote do
      unquote(warnings)
      unquote(getters)
      unquote(setters)
    end
  end

  defp reserved_vs_allowed_fields(fields) do
    fields
    |> field_names()
    |> Enum.split_with(&reserved_field?/1)
  end

  defp field_names(fields) do
    if Keyword.keyword?(fields) do
      Keyword.keys(fields)
    else
      fields
    end
  end

  defp reserved_field?(name) do
    name in @reserved_field_names
  end

  defp reserved_field_warning(field) do
    quote do
      IO.warn(
        "(StructyRecord) Field name #{inspect(unquote(field))} conflicts with existing #{
          inspect(__MODULE__)
        }.#{unquote(field)}() macro, so field accessor macros will not be defined for this name."
      )
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
