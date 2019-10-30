# StructyRecord

`StructyRecord` provides a Struct-like interface for your `Record`s.

- Use your record's macros in the _same module_ where it is defined!
- Access and update fields in your record through named macro calls.
- Create and update records at runtime (not limited to compile time).
- Calculate 1-based indexes to access record fields in `:ets` tables.

To get started, see the documentation for `StructyRecord.defrecord/3`:

    iex> h StructyRecord.defrecord

The documentation is published at <https://hexdocs.pm/structy_record>.

## Installation

The package is [available in Hex](https://hex.pm/packages/structy_record) and can
be installed by adding `structy_record` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:structy_record, "~> 0.1.0", runtime: false}
  ]
end
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
