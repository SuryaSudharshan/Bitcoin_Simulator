defmodule Blockchain.Miner do
  @server Blockchain.Miner.Server

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_args) do
    GenServer.start_link(@server, %{}, name: @server)
  end

  def stop_mining do
    GenServer.call(@server, {:stop_mining}, 12_000)
  end

  def start_mining do
    GenServer.call(@server, {:start_mining})
  end

  def get_state do
    GenServer.call(@server, {:get_state})
  end
end
