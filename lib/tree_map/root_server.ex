defmodule TreeMap.RootServer do
  @moduledoc """
  A server to maintain a list of root nodes as a DynamicSupervisor.


  Don't call this module directly. Use the `TreeMap` module instead.

  ### Examples

      iex> TreeMap.list_roots()
      [%Node{}, ...]

      iex> TreeMap.find("key")
      %Node{}

      iex> TreeMap.drop_all()
      [:ok, ...]
  """
  use DynamicSupervisor
  alias TreeMap.Node

  @doc """
  Start the DynamicSupervisor as a singleton.
  """
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Start a new root node as supervised child.
  """
  def start_child(node) do
    DynamicSupervisor.start_child(__MODULE__, {Node, node})
  end

  @doc """
  Return the root node of each child which has no parent (roots).
  """
  def list_roots() do
    for {:undefined, pid, :worker, [TreeMap.Node]} <- Supervisor.which_children(__MODULE__) do
      Node.get_node(pid)
    end
    |> Enum.filter(fn n -> n.parent == nil end)
  end

  @doc """
  Return the root node of each child.
  """
  def list_all() do
    for {:undefined, pid, :worker, [TreeMap.Node]} <- Supervisor.which_children(__MODULE__) do
      Node.get_node(pid)
    end
  end

  @doc """
  Stop all children.
  """
  def drop_all() do
    for {:undefined, pid, :worker, [TreeMap.Node]} <- Supervisor.which_children(__MODULE__) do
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end
end
