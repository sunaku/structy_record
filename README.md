# StructyRecord

`StructyRecord` provides a Struct-like interface for your `Record`s.

- Use your record's macros in the _same module_ where it is defined!
- Access and update fields in your record through named macro calls.
- Create and update records at runtime (not limited to compile time).
- Calculate 1-based indexes to access record fields in `:ets` tables.

## Setup

The package is [available in Hex](https://hex.pm/packages/structy_record) and can
be installed by adding `structy_record` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:structy_record, "~> 0.2.1"}
  ]
end
```

## Usage

To get started, see the [documentation] for `StructyRecord.defrecord/3`:

```elixir
iex> h StructyRecord.defrecord
```

[documentation]: https://hexdocs.pm/structy_record/StructyRecord.html

### Examples

Activate this macro in your environment:

```elixir
require StructyRecord
```

Define a structy record for a rectangle:

```elixir
StructyRecord.defrecord Rectangle, [:width, :height] do
  def area(r = record()) do
    get_width(r) * get_height(r)
  end

  def perimeter(record(width: w, height: h)) do
    2 * (w + h)
  end

  def square?(record(width: same, height: same)), do: true
  def square?(_), do: false
end
```

Activate its macros in your environment:

```elixir
use Rectangle
```

Create instances of your structy record:

```elixir
rect = Rectangle.{}                        #-> {Rectangle, nil, nil}
rect = Rectangle.{[]}                      #-> {Rectangle, nil, nil}
no_h = Rectangle.{[width: 1]}              #-> {Rectangle, 1, nil}
no_w = Rectangle.{[height: 2]}             #-> {Rectangle, nil, 2}
wide = Rectangle.{[width: 10, height: 5]}  #-> {Rectangle, 10, 5}
tall = Rectangle.{[width: 4, height: 25]}  #-> {Rectangle, 4, 25}
even = Rectangle.{[width: 10, height: 10]} #-> {Rectangle, 10, 10}
```

Inspect the contents of those instances:

```elixir
rect |> Rectangle.inspect() #-> "Rectangle.{[width: nil, height: nil]}"
no_h |> Rectangle.inspect() #-> "Rectangle.{[width: 1, height: nil]}"
no_w |> Rectangle.inspect() #-> "Rectangle.{[width: nil, height: 2]}"
wide |> Rectangle.inspect() #-> "Rectangle.{[width: 10, height: 5]}"
tall |> Rectangle.inspect() #-> "Rectangle.{[width: 4, height: 25]}"
even |> Rectangle.inspect() #-> "Rectangle.{[width: 10, height: 10]}"
```

Get values of fields in those instances:

```elixir
Rectangle.{{tall, :height}}       #-> 25
Rectangle.{[height: h]} = tall; h #-> 25
tall |> Rectangle.get_height()    #-> 25
```

Set values of fields in those instances:

```elixir
Rectangle.{{even, width: 1}}    #-> {Rectangle, 1, 10}
even |> Rectangle.put(width: 1) #-> {Rectangle, 1, 10}
even |> Rectangle.put_width(1)  #-> {Rectangle, 1, 10}

Rectangle.{{even, width: 1, height: 2}}                   #-> {Rectangle, 1, 2}
even |> Rectangle.put(width: 1, height: 2)                #-> {Rectangle, 1, 2}
even |> Rectangle.put_width(1) |> Rectangle.put_height(2) #-> {Rectangle, 1, 2}
```

Use your custom code on those instances:

```elixir
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
```

## License

[Spare A Life]: https://sunaku.github.io/vegan-for-life.html
> Like my work? 👍 Please [spare a life] today as thanks! 🐄🐖🐑🐔🐣🐟✨🙊✌  
> Why? For 💕 ethics, the 🌎 environment, and 💪 health; see link above. 🙇

(the ISC license)

Copyright 2019 Suraj N. Kurapati <https://github.com/sunaku>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
