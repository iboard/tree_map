defmodule TreeMap do
  @moduledoc """
  A module to maintain a tree of the structure

  ```elixir
  %Node{ key: ..., value: ..., children: [%TreeMap{},...]}
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
  """

  alias TreeMap.{Node, RootServer}

  @doc """
  ### Examples

      iex> TreeMap.new()
      %TreeMap.Node{}

      iex> TreeMap.new(123, "hundretandtwentythree")
      %TreeMap.Node{ key: 123, value: "hundretandtwentythree"}

  """
  def new(key \\ nil, value \\ nil, children \\ []) do
    %Node{key: key, value: value, children: children}
  end

  @doc """
  Return the children of this node.
  """
  def children(tree_map), do: tree_map.children

  @doc """
  Prepend a new child to the children of this node.

  ### Example:
      iex> TreeMap.new("1", "Root") |> TreeMap.add_child("1.1", "Sub One")
      %TreeMap.Node{key: "1", value: "Root", children: [%TreeMap.Node{key: "1.1", value: "Sub One"}]}
  """
  def add_child(tree_map, key, value, children \\ []) do
    %{tree_map | children: [new(key, value, children) | tree_map.children]}
  end

  @doc """
  Prepend an exisitng child to the children of this node.

  ### Example:
      iex> child = TreeMap.new("0", "I exist")
      iex> TreeMap.new("1", "Root") |> TreeMap.add_child(child)
      %TreeMap.Node{key: "1", value: "Root", children: [%TreeMap.Node{key: "0", value: "I exist"}]}
  """
  def add_child(tree_map, child) do
    %{tree_map | children: [child | tree_map.children]}
  end

  @doc """
  Traverse the tree map and apply the given function to each node.

  ### Example: 
      iex> root = TreeMap.new("1", "Root") |> TreeMap.add_child("1.1", "Sub One") |> TreeMap.add_child("1.2", "Sub Two")
      ...> TreeMap.traverse(root, fn x -> x.key end)
      ["1", ["1.1", [], "1.2", []]]
        
  """
  def traverse(tree_map, fun) do
    [
      fun.(tree_map)
      | [
          Enum.flat_map(Enum.reverse(tree_map.children), fn child ->
            traverse(child, fun)
          end)
        ]
    ]
  end

  @doc """
  Traverse the tree map and apply the given function to each node 
    and a reducer-function to it's children.

  ### Example: 
      iex> root = TreeMap.new("1", "Root") 
      ...>        |> TreeMap.add_child("1.1", "Sub One", [TreeMap.new("1.1.1", "SomeSubSub")]) 
      ...>        |> TreeMap.add_child("1.2", "Sub Two", [TreeMap.new("1.2.1", "Some other SubSub")])
      ...> TreeMap.transduce(root, 38, fn a, x -> a + Enum.count(x.children) end, fn x, acc -> acc + x end)
      42

      iex> root = TreeMap.new("1", "Root") 
      ...>        |> TreeMap.add_child("1.1", "Sub One", [TreeMap.new("1.1.1", "SomeSubSub")]) 
      ...>        |> TreeMap.add_child("1.2", "Sub Two", [TreeMap.new("1.2.1", "Some other SubSub")])
      ...> TreeMap.transduce(root, [], fn a, x -> a ++ [x.value] end, fn n, acc -> [n | acc] end) 
      ["Root", "Sub One", "SomeSubSub", "Sub Two", "Some other SubSub"]

      iex> root = TreeMap.new("1", "Root") 
      ...>        |> TreeMap.add_child("1.1", "Sub One", [TreeMap.new("1.1.1", "SomeSubSub")]) 
      ...>        |> TreeMap.add_child("1.2", "Sub Two", [TreeMap.new("1.2.1", "Some other SubSub")])
      ...> TreeMap.transduce(root, [], fn a, x -> a ++ [x] end, fn n, acc -> [n | acc] end) 
      ...> |> Enum.map(& &1.key)
      ["1", "1.1", "1.1.1", "1.2", "1.2.1"]
  """
  def transduce(tree_map, acc, modifier, reducer) do
    Enum.reduce(Enum.reverse(tree_map.children), modifier.(acc, tree_map), fn n, a ->
      transduce(n, a, modifier, reducer)
    end)
  end

  @doc """
  Find a node by it's key or returns `false` in a given tree.
  """
  def find(tree_map, key) do
    transduce(tree_map, nil, fn a, n -> a || (n.key == key && n) end, fn n, acc ->
      (n.key == key && n) || acc
    end)
  end

  @doc """
  Find a node by it's key or returns `false` in all root nodes.
  """
  def find(key) do
    list_roots()
    |> Enum.reduce(false, fn node, found ->
      found || find(node, key)
    end)
  end

  @doc """
  Create a Node and start a RootServer for it.
  """
  def start_root_node(key, value) do
    node = new(key, value)
    RootServer.start_child(node)
  end

  @doc """
  Start a root_node for the given `%Node{}`.
  """
  def start_root_node(node) do
    RootServer.start_child(node)
  end

  @doc """
  Retreive the value of a given root node.
  """
  def value(root_pid) do
    Node.value(root_pid)
  end

  @doc """
  List all root nodes from all RootServers.
  """
  def list_roots() do
    RootServer.list_roots()
  end

  @doc """
  Kill all RootServers.
  """
  def drop_all() do
    RootServer.drop_all()
  end
end
