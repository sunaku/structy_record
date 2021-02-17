defmodule StructyRecord do
  @moduledoc """

  `StructyRecord` provides a Struct-like interface for your `Record`s.

  - Use your record's macros in the _same module_ where it is defined!
  - Access and update fields in your record through named macro calls.
  - Create and update records at runtime (not limited to compile time).
  - Calculate 1-based indexes to access record fields in `:ets` tables.

  """

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

  Guards (available at compile time):
  - `is_record/1` to check if argument _loosely_ matches this record's shape

  Macros (available at compile time):
  - `{}/0` to create a new record with default values for all fields
  - `{}/1` to create a new record with the given fields and values
  - `{}/1` to get the zero-based index of the given field in a record
  - `{{}}/1` to convert a record into a list of its fields and values
  - `{{}}/2` to get the value of a given field in a given record
  - `{{}}/2` to assign the given fields and values in a given record
  - `record?/1` to check if argument _strictly_ matches this record's shape
  - `record/0` to create a new record with default values for all fields
  - `record/1` to create a new record with the given fields and values
  - `record/1` to get the zero-based index of the given field in a record
  - `record/1` to convert a record into a list of its fields and values
  - `record/2` to get the value of a given field in a given record
  - `record/2` to assign the given fields and values in a given record
  - `get/2` to fetch the value of a given field in a given record
  - `put/2` to assign the given fields and values inside a given record
  - `get_${field}/1` to fetch the value of a specific field in a given record
  - `put_${field}/2` to assign the value of a specific field in a given record
  - `index/1` to get the zero-based index of the given field in a record
  - `keypos/1` to get the 1-based index of the given field in a record
  - `to_list/0` to get a template of fields and default values for this record
  - `to_list/1` to convert a record into a list of its fields and values

  Functions (available at runtime only):
  - `matchspec_head/1` to build a MatchHead expression for use in ETS MatchSpec
  - `from_list/1` to create a new record with the given fields and values
  - `merge/2` to assign the given fields and values inside a given record
  - `inspect/2` to inspect the contents of a record using `Kernel.inspect/2`

  ## Examples

  Activate this macro in your environment:

      require StructyRecord

  Define a structy record for a rectangle:

      StructyRecord.defrecord Rectangle, [:width, :height] do
        def area(r=record()) do
          get_width(r) * get_height(r)
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

      rect = Rectangle.{}                        #-> {Rectangle, nil, nil}
      rect = Rectangle.{[]}                      #-> {Rectangle, nil, nil}
      no_h = Rectangle.{[width: 1]}              #-> {Rectangle, 1, nil}
      no_w = Rectangle.{[height: 2]}             #-> {Rectangle, nil, 2}
      wide = Rectangle.{[width: 10, height: 5]}  #-> {Rectangle, 10, 5}
      tall = Rectangle.{[width: 4, height: 25]}  #-> {Rectangle, 4, 25}
      even = Rectangle.{[width: 10, height: 10]} #-> {Rectangle, 10, 10}

  Inspect the contents of those instances:

      rect |> Rectangle.inspect() #-> "Rectangle.{[width: nil, height: nil]}"
      no_h |> Rectangle.inspect() #-> "Rectangle.{[width: 1, height: nil]}"
      no_w |> Rectangle.inspect() #-> "Rectangle.{[width: nil, height: 2]}"
      wide |> Rectangle.inspect() #-> "Rectangle.{[width: 10, height: 5]}"
      tall |> Rectangle.inspect() #-> "Rectangle.{[width: 4, height: 25]}"
      even |> Rectangle.inspect() #-> "Rectangle.{[width: 10, height: 10]}"

  Get values of fields in those instances:

      Rectangle.{{tall, :height}}       #-> 25
      Rectangle.{[height: h]} = tall; h #-> 25
      tall |> Rectangle.get_height()    #-> 25

  Set values of fields in those instances:

      Rectangle.{{even, width: 1}}    #-> {Rectangle, 1, 10}
      even |> Rectangle.put(width: 1) #-> {Rectangle, 1, 10}
      even |> Rectangle.put_width(1)  #-> {Rectangle, 1, 10}

      Rectangle.{{even, width: 1, height: 2}}                   #-> {Rectangle, 1, 2}
      even |> Rectangle.put(width: 1, height: 2)                #-> {Rectangle, 1, 2}
      even |> Rectangle.put_width(1) |> Rectangle.put_height(2) #-> {Rectangle, 1, 2}

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
    definition = alias |> append_alias(:StructyRecord)
    field_names = fields |> field_names()

    quote do
      require Record, as: StructyRecord_Record

      defmodule unquote(definition) do
        @moduledoc false
        StructyRecord_Record.defrecord(:record, unquote(alias), unquote(fields))
      end

      defmodule unquote(alias) do
        require unquote(definition), as: StructyRecord_Definition
        alias __MODULE__, as: StructyRecord_Interface

        defmacro __using__(_options) do
          quote do
            require StructyRecord_Definition
            require StructyRecord_Interface
          end
        end

        unquote(record_primitives())
        unquote(elixiry_interface(field_names))
        unquote(field_accessors(field_names))
        unquote(do_block)
      end
    end
  end

  defp append_alias({tag = :__aliases__, context, namespace}, addendum) do
    {tag, context, namespace ++ [addendum]}
  end

  defp record_primitives do
    quote do
      @doc """
      Creates a new record with fields set to default values.
      """
      defmacro {} do
        quote do
          StructyRecord_Definition.record()
        end
      end

      @doc """
      Either fetches the value of a given field in a given record,
      or assigns the given fields and values inside a given record.
      """
      defmacro {{record, field_or_contents}} do
        quote do
          StructyRecord_Definition.record(unquote(record), unquote(field_or_contents))
        end
      end

      @doc """
      Converts the given record into a list of its fields and values.
      """
      defmacro {{_tag = :{}, _context, [record]}} do
        quote do
          StructyRecord_Definition.record(unquote(record))
        end
      end

      @doc """
      Either creates a new record with the given fields and values,
      or returns the zero-based index of the given field in a record.
      """
      defmacro {contents_or_field_or_record} do
        quote do
          StructyRecord_Definition.record(unquote(contents_or_field_or_record))
        end
      end

      @doc """
      Either creates a new record with the given fields and values,
      or returns the zero-based index of the given field in a record,
      or converts the given record into a list of its fields and values.
      Defaults to creating a new record with fields set to default values.
      """
      defmacro record(contents_or_field_or_record \\ []) do
        quote do
          StructyRecord_Definition.record(unquote(contents_or_field_or_record))
        end
      end

      @doc """
      Either fetches the value of a given field in a given record,
      or assigns the given fields and values inside a given record.
      """
      defmacro record(record, field_or_contents) do
        quote do
          StructyRecord_Definition.record(unquote(record), unquote(field_or_contents))
        end
      end

      @doc """
      Checks if the given argument _loosely_ matches this record's shape.
      """
      defguard is_record(record)
               when record
                    |> StructyRecord_Record.is_record(StructyRecord_Interface)

      @doc """
      Checks if the given argument _strictly_ matches this record's shape.
      """
      defmacro record?(record) do
        quote do
          match?(StructyRecord_Definition.record(), unquote(record))
        end
      end
    end
  end

  defp elixiry_interface(field_names) do
    quote do
      @record StructyRecord_Definition.record()
      @template StructyRecord_Definition.record(@record)
      @matchspec_head_template unquote(field_names) |> Enum.map(&{&1, :_})

      @doc """
      Returns the zero-based index of the given field in this kind of record.
      """
      defmacro index(field) when is_atom(field) do
        quote do
          StructyRecord_Definition.record(unquote(field))
        end
      end

      defmacro index(field) do
        quote bind_quoted: [field: field, template: @template] do
          StructyRecord.index(field, StructyRecord_Interface, template)
        end
      end

      @doc """
      Returns the 1-based position of the given field in this kind of record.
      """
      defmacro keypos(field) do
        quote do
          1 + StructyRecord_Definition.record(unquote(field))
        end
      end

      @doc """
      Returns a template of fields and default values for this kind of record.
      """
      defmacro to_list do
        quote do
          unquote(@template)
        end
      end

      @doc """
      Converts the given record into a `Keyword` list of its fields and values.
      """
      defmacro to_list(record) do
        quote do
          StructyRecord_Definition.record(unquote(record))
        end
      end

      @doc """
      Fetches the value of the given field in the given record.
      """
      defmacro get(record, field) do
        quote do
          StructyRecord_Definition.record(unquote(record), unquote(field))
        end
      end

      @doc """
      Assigns the given fields and values inside a given record.
      """
      defmacro put(record, contents) do
        quote do
          StructyRecord_Definition.record(unquote(record), unquote(contents))
        end
      end

      @doc """
      Builds a MatchHead expression _at runtime_ for use in an ETS MatchSpec,
      where the given fields & values are passed through verbatim and all the
      unmentioned fields in the record definition are set to `:_` wildcards.
      """
      def matchspec_head(contents) do
        StructyRecord.from_list(contents, StructyRecord_Interface, @matchspec_head_template)
      end

      @doc """
      Creates a new record _at runtime_ with the given fields and values.
      """
      def from_list(contents) do
        StructyRecord.from_list(contents, StructyRecord_Interface, @template)
      end

      @doc """
      Assigns the given fields and values _at runtime_ inside a given record.
      """
      def merge(record, contents) do
        template = record |> StructyRecord_Definition.record()
        StructyRecord.from_list(contents, StructyRecord_Interface, template)
      end

      @doc """
      Inspects the given record's contents _at runtime_ using `Kernel.inspect/2`.
      """
      def inspect(record, options \\ []) do
        contents = record |> StructyRecord_Definition.record()
        StructyRecord.inspect(contents, StructyRecord_Interface, options)
      end
    end
  end

  defp field_accessors(field_names) do
    getters = field_names |> Enum.map(&getter_macro/1)
    putters = field_names |> Enum.map(&putter_macro/1)

    quote do
      unquote(getters)
      unquote(putters)
    end
  end

  defp field_names(fields) do
    fields
    |> Enum.map(fn
      {field, _default_value} -> field
      field -> field
    end)
  end

  defp getter_macro(field) do
    quote do
      @doc """
      Fetches the value of the `#{unquote(inspect(field))}` field in the given record.
      """
      defmacro unquote(:"get_#{field}")(record) do
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

  defp putter_macro(field) do
    quote do
      @doc """
      Assigns the value of the `#{unquote(inspect(field))}` field in the given record.
      """
      defmacro unquote(:"put_#{field}")(record, value) do
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

  @doc """
  Returns the zero-based index of the given field in the given kind of record.
  """
  def index(field, record_tag, record_template) do
    case find_index(record_template, field) do
      nil ->
        # error out in _exactly_ the same way as Record.index/3 for uniformity
        raise ArgumentError,
              "record #{inspect(record_tag)} does not have the key: #{inspect(field)}"

      index ->
        # add +1 for record_tag which occupies the first position in the tuple
        1 + index
    end
  end

  defp find_index(template, field) do
    template
    |> Enum.find_index(&match?({^field, _default_value}, &1))
  end

  @doc """
  Creates a new record of the given type with the given fields and values.
  """
  def from_list(contents, record_tag) do
    values = Keyword.values(contents)
    [record_tag | values] |> :erlang.list_to_tuple()
  end

  @doc """
  Creates a new record of the given type with the given fields and values
  according to the given template of known fields and their default values.
  """
  def from_list(contents, record_tag, record_template) do
    contents
    |> intersect(record_template)
    |> from_list(record_tag)
  end

  defp intersect(contents, template) do
    template
    |> Enum.map(fn {field, template_value} ->
      value = Access.get(contents, field, template_value)
      {field, value}
    end)
  end

  @doc """
  Inspects the contents of the given record type using `Kernel.inspect/2`.
  """
  def inspect(contents, record_tag, options \\ []) when is_list(contents) do
    "#{inspect(record_tag)}.{#{inspect_contents(contents, options)}}"
  end

  defp inspect_contents([], _), do: ""
  defp inspect_contents(list, options), do: Kernel.inspect(list, options)
end
