defmodule Blockchain.TransactionsPool do
  @server Blockchain.TransactionsPool.Server

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
    GenServer.start_link(@server, [], name: @server)
  end

  def add_transaction(transaction) do
    GenServer.call(@server, {:add_transaction, transaction})
  end

  def get_all_transactions_and_flush_pool do
    GenServer.call(@server, {:get_all_transactions_and_flush_pool})
  end

  def get_all_transactions do
    GenServer.call(@server, {:get_all_transactions})
  end
end
