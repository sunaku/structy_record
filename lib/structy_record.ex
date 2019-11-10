defmodule StructyRecord do
  @moduledoc """

  `StructyRecord` provides a Struct-like interface for your `Record`s.

  - Use your record's macros in the _same module_ where it is defined!
  - Access and update fields in your record through named macro calls.
  - Create and update records at runtime (not limited to compile time).
  - Calculate 1-based indexes to access record fields in `:ets` tables.

  """

  @reserved_field_names [:record, :record!, :record?, :index, :keypos, :inspect, :to_list]

  @doc """
  Defines a module named `alias` that is also a `Record` composed of `fields`.

  ## Parameters

  - `alias` is the name of the module being defined.  It also serves as the
  `tag` parameter of `Record.defrecord/3`, which helps identify the record.

  - `fields` specifies the shape of the record being defined.  It is either:
    - a list of `Atom` field names whose default values are always `nil`
    - a `Keyword` list of field names along with their own default values

  - `do_block` is an optional block of code that is passed into `defmodule/2`.
  It allows you to extend the module being defined with your own custom code,
  which has compile-time access to all the guards and macros described below.

  ## Results

  The defined module provides the following guards, macros, and functions.

  Guards:
  - `is_record/1` to check if argument _loosely_ matches this record's shape

  Macros:
  - `record?/1` to check if argument _strictly_ matches this record's shape
  - `record/0` to create a new record with default values for all fields
  - `record/1` to create a new record with the given fields and values
  - `record/1` to get the zero-based index of the given field in a record
  - `record/1` to convert the given record into a `Keyword` list
  - `record/2` to get the value of a given field in a given record
  - `record/2` to update an existing record with the given fields and values
  - `${field}/1` to get the value of a specific field in a given record
  - `${field}/2` to set the value of a specific field in a given record
  - `index/1` to get the zero-based index of the given field in a record
  - `keypos/1` to get the 1-based index of the given field in a record
  - `to_list/1` to convert the given record into a `Keyword` list

  Functions:
  - `record!/1` to create a new record _at runtime_ with the given fields and values
  - `record!/2` to update an existing record with the given fields and values
  - `inspect/2` to inspect the contents of a record using `Kernel.inspect/2`

  ## Examples

  Activate this macro in your environment:

      require StructyRecord

  Define a structy record for a rectangle:

      StructyRecord.defrecord Rectangle, [:width, :height] do
        def area(r=record()) do
          width(r) * height(r)
        end

        def perimeter(record(width: w, height: h)) do
          2 * (w + h)
        end

        def square?(record(width: same, height: same)), do: true
        def square?(_), do: false
      end

  Activate its macros in your environment:

      use Rectangle

  Create instances of your structy record:

      rect = Rectangle.record()                      #-> {Rectangle, nil, nil}
      no_h = Rectangle.record(width: 1)              #-> {Rectangle, 1, nil}
      no_w = Rectangle.record(height: 2)             #-> {Rectangle, nil, 2}
      wide = Rectangle.record(width: 10, height: 5)  #-> {Rectangle, 10, 5}
      tall = Rectangle.record(width: 4, height: 25)  #-> {Rectangle, 4, 25}
      even = Rectangle.record(width: 10, height: 10) #-> {Rectangle, 10, 10}

  Inspect the contents of those instances:

      rect |> Rectangle.inspect() #-> "Rectangle.record(width: nil, height: nil)"
      no_h |> Rectangle.inspect() #-> "Rectangle.record(width: 1, height: nil)"
      no_w |> Rectangle.inspect() #-> "Rectangle.record(width: nil, height: 2)"
      wide |> Rectangle.inspect() #-> "Rectangle.record(width: 10, height: 5)"
      tall |> Rectangle.inspect() #-> "Rectangle.record(width: 4, height: 25)"
      even |> Rectangle.inspect() #-> "Rectangle.record(width: 10, height: 10)"

  Get values of fields in those instances:

      tall |> Rectangle.height()            #-> 25
      tall |> Rectangle.record(:height)     #-> 25
      Rectangle.record(height: h) = tall; h #-> 25

  Set values of fields in those instances:

      even |> Rectangle.width(1)         #-> {Rectangle, 1, 10}
      even |> Rectangle.record(width: 1) #-> {Rectangle, 1, 10}

      even |> Rectangle.width(1) |> Rectangle.height(2) #-> {Rectangle, 1, 2}
      even |> Rectangle.record(width: 1, height: 2)     #-> {Rectangle, 1, 2}

  Use your custom code on those instances:

      rect |> Rectangle.area() #-> (ArithmeticError) bad argument in arithmetic expression: nil * nil
      no_h |> Rectangle.area() #-> (ArithmeticError) bad argument in arithmetic expression: 1 * nil
      no_w |> Rectangle.area() #-> (ArithmeticError) bad argument in arithmetic expression: nil * 2
      wide |> Rectangle.area() #-> 50
      tall |> Rectangle.area() #-> 100
      even |> Rectangle.area() #-> 100

      rect |> Rectangle.perimeter() #-> (ArithmeticError) bad argument in arithmetic expression: nil + nil
      no_h |> Rectangle.perimeter() #-> (ArithmeticError) bad argument in arithmetic expression: 1 + nil
      no_w |> Rectangle.perimeter() #-> (ArithmeticError) bad argument in arithmetic expression: nil + 2
      wide |> Rectangle.perimeter() #-> 30
      tall |> Rectangle.perimeter() #-> 58
      even |> Rectangle.perimeter() #-> 40

      rect |> Rectangle.square?() #-> true
      no_h |> Rectangle.square?() #-> false
      no_w |> Rectangle.square?() #-> false
      wide |> Rectangle.square?() #-> false
      tall |> Rectangle.square?() #-> false
      even |> Rectangle.square?() #-> true

  """
  defmacro defrecord(alias, fields, do_block \\ []) do
    definition = alias |> concat_alias([:StructyRecord])

    quote do
      require Record, as: StructyRecord_Record

      defmodule unquote(definition) do
        StructyRecord_Record.defrecord(:record, unquote(alias), unquote(fields))
      end

      defmodule unquote(alias) do
        require unquote(definition), as: StructyRecord_Definition
        alias __MODULE__, as: StructyRecord_Interface

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
          require StructyRecord_Definition
          require StructyRecord_Interface
        end
      end
    end
  end

  defp record_macros() do
    quote do
      def record!(contents) do
        record!(StructyRecord_Definition.record(), contents)
      end

      def record!(record, updates) do
        template = record |> StructyRecord_Definition.record()

        contents =
          template
          |> Enum.map(fn {field, default_value} ->
            Access.get(updates, field, default_value)
          end)

        [StructyRecord_Interface | contents] |> :erlang.list_to_tuple()
      end

      defmacro record(record_or_contents \\ []) do
        quote do
          StructyRecord_Definition.record(unquote(record_or_contents))
        end
      end

      defmacro record(record, updates) do
        quote do
          StructyRecord_Definition.record(unquote(record), unquote(updates))
        end
      end

      defmacro record?(record) do
        quote do
          match?(StructyRecord_Definition.record(), unquote(record))
        end
      end

      defmacro to_list(record) do
        quote do
          if StructyRecord_Interface.record?(unquote(record)) do
            StructyRecord_Definition.record(unquote(record))
          else
            raise ArgumentError,
                  "expected a #{inspect(StructyRecord_Interface)} record, got #{
                    inspect(unquote(record))
                  }"
          end
        end
      end

      def inspect(record, options \\ []) do
        options_without_label = Keyword.delete(options, :label)
        inspect(record, options_without_label, options[:label])
      end

      defp inspect(record, options_without_label, _label = nil) do
        inspect =
          record
          |> StructyRecord_Definition.record()
          |> Kernel.inspect(options_without_label)

        # omit enclosing [] square brackets from inspected Keyword list
        length_of_contents = byte_size(inspect) - 2
        <<?[, contents::binary-size(length_of_contents), ?]>> = inspect

        "#{inspect(StructyRecord_Interface)}.record(#{contents})"
      end

      defp inspect(record, options_without_label, label) do
        inspect = inspect(record, options_without_label, _label = nil)
        "#{label}: #{inspect}"
      end

      defguard is_record(record)
               when record
                    |> StructyRecord_Record.is_record(StructyRecord_Interface)
    end
  end

  defp keypos_macros() do
    quote do
      defmacro index(args) do
        quote do
          StructyRecord_Definition.record(unquote(args))
        end
      end

      defmacro keypos(args) do
        quote do
          1 + StructyRecord_Interface.index(unquote(args))
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
          inspect(StructyRecord_Interface)
        }.#{unquote(field)}() macro, so field accessor macros will not be defined for this name."
      )
    end
  end

  defp getter_macro(field) do
    quote do
      defmacro unquote(field)(record) do
        quote do
          StructyRecord_Definition.record(unquote(record), :field)
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
          StructyRecord_Definition.record(unquote(record), unquote(value))
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
