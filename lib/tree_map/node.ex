defmodule TreeMap.Node do
  @moduledoc """
  `Node` can be used as a simple structure, representing a node in a tree
  or as a GenServer to store the Node structure.

  Node GenServer are supervised by `TreeMap.RootServer` and should 
  be started and stopped throug `TreeMap` module.
  """
  defstruct key: nil, value: nil, children: []

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
  def node(pid) do
    GenServer.call(pid, :node)
  end

  @doc """
  Returns the value of the `%Node{}` struct of this process.
  """
  def value(pid) do
    GenServer.call(pid, :value)
  end

  @impl true
  def handle_call(:node, _, %__MODULE__{} = state) do
    {:reply, state, state}
  end

  def handle_call(:value, _, %__MODULE__{value: value} = state) do
    {:reply, value, state}
  end
end
