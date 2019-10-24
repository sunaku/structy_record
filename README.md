# StructyRecord

`StructyRecord` provides a Struct-like interface for your `Record`s.

- Use your record's macros in the _same module_ where it is defined!
- Access and update fields in your record through named macro calls.
- Create and update records at runtime (not limited to compile time).
- Calculate 1-based indexes to access record fields in `:ets` tables.

To get started, see the documentation for `StructyRecord.defrecord/3`:

    iex> h StructyRecord.defrecord

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `structy_record` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:structy_record, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/structy_record](https://hexdocs.pm/structy_record).

## License

[Spare A Life]: https://sunaku.github.io/vegan-for-life.html
> Like my work? 👍 Please [spare a life] today as thanks! 🐮🐷🐔🐟🙊✌💞✨ <br>
> For 💕 ethics, 🌎 environment, and 💪 health: learn more at link above. 🙇🙏

Copyright 2019 Suraj N. Kurapati <https://github.com/sunaku>

Distributed under the terms of the ISC license (see the LICENSE file).
