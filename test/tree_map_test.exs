defmodule TreeMapTest do
  use ExUnit.Case
  doctest TreeMap

  test "initialize a TreeMap" do
    assert TreeMap.new() == %TreeMap{key: nil, value: nil, children: []}
    assert TreeMap.new(1, :foo) == %TreeMap{key: 1, value: :foo, children: []}
  end

  test "add child" do
    child = TreeMap.new("1.3", "added as a map")

    root =
      TreeMap.new("1", "Root")
      |> TreeMap.add_child("1.1", "Subtree A")
      |> TreeMap.add_child("1.2", "Subtree B")
      |> TreeMap.add_child(child)

    assert TreeMap.children(root) |> Enum.count() == 3
  end

  test "traverse" do
    root =
      TreeMap.new("1", "Root")
      |> TreeMap.add_child("1.1", "Subtree A")
      |> TreeMap.add_child("1.2", "Subtree B")

    assert TreeMap.traverse(root, fn node ->
             "#{node.key} #{node.value}"
           end) == [
             "1 Root",
             [
               "1.1 Subtree A",
               [],
               "1.2 Subtree B",
               []
             ]
           ]

    assert [2 | _] = TreeMap.traverse(root, fn node -> Enum.count(node.children) end)
  end

  test "flatten the tree with transduce" do
    root =
      TreeMap.new("1", "Root")
      |> TreeMap.add_child("1.1", "Sub One", [TreeMap.new("1.1.1", "SomeSubSub")])
      |> TreeMap.add_child("1.2", "Sub Two", [TreeMap.new("1.2.1", "Some other SubSub")])

    expected = ["1", "1.1", "1.1.1", "1.2", "1.2.1"]

    received =
      TreeMap.transduce(root, [], fn a, x -> a ++ [x] end, fn n, acc -> [n | acc] end)
      |> Enum.map(& &1.key)

    assert expected == received
  end

  test "deep sum with transduce" do
    root =
      TreeMap.new("1", "Root")
      |> TreeMap.add_child("1.1", "Sub One", [TreeMap.new("1.1.1", "SomeSubSub")])
      |> TreeMap.add_child("1.2", "Sub Two", [TreeMap.new("1.2.1", "Some other SubSub")])

    result =
      TreeMap.transduce(root, 38, fn a, x -> a + Enum.count(x.children) end, fn x, acc ->
        acc + x
      end)

    assert 42 == result
  end

  test "family tree" do
    prokop = create_family_tree()

    assert TreeMap.traverse(prokop, fn node ->
             "#{node.value}"
           end) == [
             "Prokop",
             [
               "Gerda",
               [
                 "Margit",
                 [],
                 "Heidi",
                 ["Alex", [], "Julian", []],
                 "Elke",
                 ["Hanna", [], "Jan", []]
               ],
               "Helmut",
               []
             ]
           ]
  end

  test "find" do
    prokop = create_family_tree()

    jan = TreeMap.find(prokop, "1.1.1.1")
    false = TreeMap.find(prokop, "not found")

    assert jan.value == "Jan"
  end

  defp create_family_tree() do
    helmut = TreeMap.new("1.2", "Helmut")

    margit = TreeMap.new("1.1.3", "Margit")

    jan = TreeMap.new("1.1.1.1", "Jan")
    hanna = TreeMap.new("1.1.1.2", "Hanna")
    elke = TreeMap.new("1.1.1", "Elke", [jan, hanna])

    julian = TreeMap.new("1.1.2.1", "Julian")
    alex = TreeMap.new("1.1.2.2", "Alex")
    heidi = TreeMap.new("1.1.2", "Heidi", [julian, alex])

    gerda = TreeMap.new("1.1", "Gerda", [elke, heidi, margit])

    TreeMap.new("1", "Prokop", [helmut, gerda])
  end
end
