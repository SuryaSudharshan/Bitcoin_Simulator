defmodule Blockchain.TransactionsPool.Server do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def handle_call({:add_transaction, transaction}, _, state) do
    {:reply, :ok, state ++ [transaction]}
  end

  def handle_call({:get_all_transactions_and_flush_pool}, _, state) do
    {:reply, state, []}
  end

  def handle_call({:get_all_transactions}, _, state) do
    {:reply, state, state}
  end
end
