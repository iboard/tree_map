# TreeMap

A module to maintain a tree of the structure

```elixir
  %TreeMap{ key: ..., value: ..., children: [%TreeMap{},...]}
```

and functions to traverse such a tree.

### Examples

```elixir
 root =
   TreeMap.new("1", "Root")
   |> TreeMap.add_child("1.1", "Sub One", [TreeMap.new("1.1.1", "SomeSubSub")])
   |> TreeMap.add_child("1.2", "Sub Two", [TreeMap.new("1.2.1", "Some other SubSub")])

 expected = ["1", "1.1", "1.1.1", "1.2", "1.2.1"]

 received =
   TreeMap.transduce(root, [], fn a, x -> a ++ [x] end, fn n, acc -> [n | acc] end)
   |> Enum.map(& &1.key)

 assert expected == received
```


## Installation

[Available in Hex](https://hexdocs.pm/tree_map/api-reference.html), the package can be 
installed by adding `tree_map` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tree_map, "~> 0.1.0"}
  ]
end
```


