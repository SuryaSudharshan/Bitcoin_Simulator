defmodule Blockchain.Chain.Server do
  alias Blockchain.{
    Core.Block
  }

  use GenServer

  def init(args) do
    {:ok, args}
  end

  def handle_call({:get_state}, _, state) do
    {:reply, state, state}
  end

  def handle_call({:fetch_initial_chain}, _, _) do
    {:reply, :ok, [Block.genesis_block()]}
  end

  def handle_call({:get_most_recent_block}, _, state) do
    get_most_recent_block = List.last(state)
    {:reply, get_most_recent_block, state}
  end

  def handle_call({:get_most_recent_block_hash}, _, state) do
    get_most_recent_block = List.last(state)
    get_most_recent_block = Block.hash_block(get_most_recent_block)

    {:reply, get_most_recent_block, state}
  end

  def handle_call({:put_block, block}, _, state) do
    {:reply, :ok, state ++ [block]}
  end
end
