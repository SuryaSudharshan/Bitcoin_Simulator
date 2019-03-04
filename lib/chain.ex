defmodule Blockchain.Chain do
  alias Blockchain.{
    Core.Block
  }

  @server Blockchain.Chain.Server

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
    GenServer.start_link(@server, [Block.genesis_block()], name: @server)
  end

  def fetch_initial_chain do
    GenServer.call(@server, {:fetch_initial_chain})
  end

  def get_state do
    GenServer.call(@server, {:get_state})
  end

  def get_most_recent_block do
    GenServer.call(@server, {:get_most_recent_block})
  end

  def get_most_recent_block_hash do
    GenServer.call(@server, {:get_most_recent_block_hash})
  end

  def put_block(block) do
    GenServer.call(@server, {:put_block, block})
  end
end
