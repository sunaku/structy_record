## Version 0.2.0 (2021-02-18)

This release adds a convenient new shorthand syntax for the `record()` macro,
renames field accessors to prevent name collisions, clarifies docs, and more.

### Incompatible:

  * Rename `record!/1` function to `from_list/1`.

  * Rename `record!/2` function to `merge/2`.

  * Add `get_` and `put_` prefix to field accessors.

    Field names can no longer conflict with defined macros & functions.

  * Don't check argument types in Elixiry interface.

    It broke simple macro expansion when used in case/function clauses.

### Enhancements:

  * Add `Module.{_}` syntax for `Module.record(_)`.

    https://stackoverflow.com/a/51313720/120075

  * Add `inspect/2` for friendlier inspection.

  * Add `to_list/0` to get record's template.

  * Add `to_list/1` alias for `record/1` macro.

  * Add `index/1` to get field index in tuple.

  * Add `get/2` macro as an alias to `record/2`.

  * Add `put/2` macro as an alias to `record/2`.

  * Define documentation for all macros and functions.

### Housekeeping:

  * `record?/1` macro: only use pattern matching check.

  * `keypos/1` macro: don't call module being defined.

  * mix.exs: drop application(); use `runtime: false`.

## Version 0.1.0 (2019-10-26)

Initial release! 🎉 Announced on [ElixirForum] and [Reddit].

[ElixirForum]: https://elixirforum.com/t/26367
[Reddit]: https://www.reddit.com/r/elixir/comments/dni8zb
