defmodule TreeMap.Application do
  @moduledoc false

  use Application

  alias TreeMap.RootServer

  @impl true
  def start(_type, _args) do
    children = [
      {RootServer, []}
    ]

    opts = [strategy: :one_for_one, name: TreeMap.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
