defmodule TreeMapServerTest do
  use ExUnit.Case

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

  defp create_family_tree(name \\ "Prokop")

  defp create_family_tree("Altendorfer") do
    TreeMap.new("2", "Altendorfer", [
      TreeMap.new("2.1", "Rudolf"),
      TreeMap.new("2.2", "Grete", [
        TreeMap.new("2.2.1", "Rudi"),
        TreeMap.new("2.2.2", "Andreas")
      ])
    ])
  end

  defp create_family_tree("Prokop") do
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
