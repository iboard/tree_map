# README 
## TreeMap 0.1


[![Elixir CI](https://github.com/iboard/tree_map/actions/workflows/elixir.yml/badge.svg)](https://github.com/iboard/tree_map/actions/workflows/elixir.yml)
[![Package version](http://img.shields.io/hexpm/v/tree_map.svg?style=flat)](https://hex.pm/packages/tree_map)
[![Package documentation](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/tree_map)

A module to maintain a tree of the structure `TreeMap.Node` and to start root-nodes as 
supervised children of `TreeMap.RootServer`.

### Node Structure

```elixir
  %Node{ key: ..., value: ..., children: [%Node{},...]}
```

### Function to traverse `%Node{}`

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

### RootServer

`TreeMap.RootServer` is a `DynamicSupervisor` that can be used to maintain a tree of `TreeMap` nodes.

    iex> TreeMap.start_root_node("A", "Root")
    {:ok, pid}

    iex> TreeMap.list_roots()
    [%Node{}, ...]

    iex> TreeMap.find("key")
    %Node{}

    iex> TreeMap.drop_all()
    [:ok, ...]


## Installation

[Available in Hex](https://hex.pm/packages/tree_map), the package can be 
installed by adding `tree_map` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tree_map, "~> 0.1.0"}
  ]
end
```


