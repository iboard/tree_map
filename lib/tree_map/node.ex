defmodule TreeMap.Node do
  @moduledoc """
  `Node` can be used as a simple structure, representing a node in a tree
  or as a GenServer to store the Node structure.

  Node GenServer are supervised by `TreeMap.RootServer` and should 
  be started and stopped throug `TreeMap` module.
  """
  defstruct key: nil, value: nil, parent: nil, children: []
  alias __MODULE__

  use GenServer

  def start_link(%__MODULE__{} = node, opts \\ []) do
    GenServer.start_link(__MODULE__, node, opts)
  end

  @impl true
  def init(node) do
    {:ok, node}
  end

  @doc """
  Return the `%Node{}` struct of this process.
  """
  def get_node(pid) when is_pid(pid) do
    GenServer.call(pid, :node)
  end

  def get_node(%Node{} = node), do: node

  @doc """
  Returns the key of the `%Node{}` struct of this process.
  """
  def key(pid) when is_pid(pid) do
    GenServer.call(pid, :key)
  end

  def key(%Node{key: k}), do: k

  @doc """
  Returns the value of the `%Node{}` struct of this process.
  """
  def value(pid) when is_pid(pid) do
    GenServer.call(pid, :value)
  end

  def value(%Node{value: v}), do: v

  @doc """
  Returns the parent of the `%Node{}` struct of this process.
  """
  def parent(pid) when is_pid(pid) do
    GenServer.call(pid, :parent)
  end

  def parent(%Node{parent: p}), do: p

  @doc """
  Update the node of the given process.
  """
  def update(pid, node) when is_pid(pid) do
    GenServer.cast(pid, {:update, node})
    get_node(pid)
  end

  @impl true
  def handle_call(:node, _, %__MODULE__{} = state) do
    {:reply, state, state}
  end

  def handle_call(:key, _, %__MODULE__{key: key} = state) do
    {:reply, key, state}
  end

  def handle_call(:value, _, %__MODULE__{value: value} = state) do
    {:reply, value, state}
  end

  def handle_call(:parent, _, %__MODULE__{parent: parent} = state) do
    {:reply, parent, state}
  end

  @impl true
  def handle_cast({:update, node}, _state) do
    {:noreply, node}
  end
end
