defmodule TreeMapServerTest do
  use ExUnit.Case

  alias TreeMap.Node

  describe "OTP basics" do
    setup %{} do
      TreeMap.drop_all()
      :ok
    end

    test "initialize the server at startup" do
      assert Process.whereis(TreeMap.Supervisor) != nil
    end

    test "add root nodes" do
      {:ok, prokop} = TreeMap.start_root_node("A", "Prokop")
      {:ok, altendorfer} = TreeMap.start_root_node("B", "Altendorfer")

      assert is_pid(prokop)
      assert is_pid(altendorfer)

      assert "Prokop" == TreeMap.value(prokop)
      assert "Altendorfer" == TreeMap.value(altendorfer)
    end

    test "list root servers" do
      prokop = create_family_tree()
      {:ok, prokop} = TreeMap.start_root_node(prokop)
      assert is_pid(prokop)
    end
  end

  describe "TreeMap with root nodes" do
    setup %{} do
      TreeMap.drop_all()
      {:ok, prokop} = TreeMap.start_root_node(create_family_tree("Prokop"))
      {:ok, altendorfer} = TreeMap.start_root_node(create_family_tree("Altendorfer"))
      {:ok, %{prokop: prokop, altendorfer: altendorfer}}
    end

    test "list nodes" do
      prokop = create_family_tree("Prokop")
      altendorfer = create_family_tree("Altendorfer")
      assert [^prokop, ^altendorfer] = TreeMap.list_roots()
    end

    test "find in all nodes" do
      # given two families
      prokop = create_family_tree("Prokop")
      altendorfer = create_family_tree("Altendorfer")

      # when search in a particular family
      jan = TreeMap.find(prokop, "1.1.1.1")
      andi = TreeMap.find(altendorfer, "2.2.2")

      # when search in all root_nodes
      ^jan = TreeMap.find("1.1.1.1")
      ^andi = TreeMap.find("2.2.2")
    end
  end

  describe "All nodes are processes" do
    setup %{} do
      TreeMap.drop_all()

      {:ok, project_one} = TreeMap.start_root_node("1", "Project One")
      {:ok, subproject_one_one} = TreeMap.start_root_node("1.1", "Subproject One One")
      {:ok, subproject_one_two} = TreeMap.start_root_node("1.2", "Subproject One Two")
      {:ok, project_two} = TreeMap.start_root_node("2", "Project Two")
      {:ok, subproject_two_one} = TreeMap.start_root_node("2.1", "Subproject Two One")

      TreeMap.add_child(project_one, subproject_one_one)
      TreeMap.add_child(project_one, subproject_one_two)
      TreeMap.add_child(project_two, subproject_two_one)

      :ok
    end

    test "Find node" do
      node = TreeMap.find("1.1")
      assert node.value == "Subproject One One"
    end

    test "Find roots only" do
      assert ["1", "2"] ==
               TreeMap.list_roots()
               |> Enum.map(&Node.key/1)
    end

    test "list all nodes with servers" do
      assert ["1", "1.1", "1.2", "2", "2.1"] ==
               TreeMap.list_all()
               |> Enum.map(&Node.key/1)
    end
  end

  defp create_family_tree(name \\ "Prokop")

  defp create_family_tree("Altendorfer") do
    grete =
      TreeMap.new("2.2", "Grete")
      |> TreeMap.add_child(TreeMap.new("2.2.1", "Rudi"))
      |> TreeMap.add_child(TreeMap.new("2.2.2", "Andreas"))

    TreeMap.new("2", "Altendorfer")
    |> TreeMap.add_child(TreeMap.new("2.1", "Rudolf"))
    |> TreeMap.add_child(grete)
  end

  defp create_family_tree("Prokop") do
    helmut = TreeMap.new("1.2", "Helmut")

    margit = TreeMap.new("1.1.3", "Margit")

    jan = TreeMap.new("1.1.1.1", "Jan")
    hanna = TreeMap.new("1.1.1.2", "Hanna")
    elke = TreeMap.new("1.1.1", "Elke") |> TreeMap.add_child(jan) |> TreeMap.add_child(hanna)

    julian = TreeMap.new("1.1.2.1", "Julian")
    alex = TreeMap.new("1.1.2.2", "Alex")
    heidi = TreeMap.new("1.1.2", "Heidi") |> TreeMap.add_child(julian) |> TreeMap.add_child(alex)

    gerda =
      TreeMap.new("1.1", "Gerda")
      |> TreeMap.add_child(elke)
      |> TreeMap.add_child(heidi)
      |> TreeMap.add_child(margit)

    TreeMap.new("1", "Prokop") |> TreeMap.add_child(helmut) |> TreeMap.add_child(gerda)
  end
end
