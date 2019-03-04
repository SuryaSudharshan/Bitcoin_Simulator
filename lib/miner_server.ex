defmodule Blockchain.Miner.Server do
  use GenServer

  alias Blockchain.{
    TransactionsPool,
    Chain,
    Wallet,
    MerkleTree
  }

  alias Blockchain.Core.{
    Head,
    Block,
    Transaction
  }

  alias Blockchain.Key.{
    KeyServer
  }

  alias Blockchain.Miner.Server.Impl

  @difficulty 4

  def init(_args) do
    state = %{
      miner: :stopped
    }

    {:ok, state}
  end

  def handle_call({:start_mining}, _from, %{miner: :running} = state) do
    {:reply, :running_already, state}
  end

  def handle_call({:start_mining}, _from, state) do
    state = %{state | miner: :running}
    Process.send(self(), :work, [:noconnect])
    {:reply, :ok, state}
  end

  def handle_call({:stop_mining}, _from, %{miner: :stopped} = state) do
    {:reply, :stopped_already, state}
  end

  def handle_call({:stop_mining}, _from, state) do
    {:reply, :ok, %{state | miner: :stopped}}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:work, state) do
    Impl.mine(state)
    {:noreply, state}
  end

  def check_transactions(transactions) do
    valid_transactions =
      Enum.reduce(transactions, [], fn transaction, valid_transactions ->
        if Transaction.is_valid?(
             Transaction.hash_transaction(transaction),
             transaction.digital_signature,
             transaction.origin_account
           ) and
             transaction.amount <=
               Wallet.check_amount(transaction.origin_account)
               |> validate_amount_post_transactions(
                 valid_transactions,
                 transaction.origin_account
               ) do
          valid_transactions ++ [transaction]
        else
          valid_transactions
        end
      end)

    valid_transactions ++ [Transaction.coinbase_transaction(KeyServer.get_miner_public_key())]
  end

  def validate_amount_post_transactions(amount, transactions, public_key) do
    Enum.reduce(transactions, amount, fn transaction, account ->
      account =
        if transaction.destination_account == public_key do
          account + transaction.amount
        else
          if transaction.origin_account == public_key do
            account - transaction.amount
          else
            account
          end
        end
    end)
  end

  def mine_block do
    valid_transactions =
      TransactionsPool.get_all_transactions_and_flush_pool() |> check_transactions()
    merkle_root = MerkleTree.get_merkle_root(Transaction.hash_transactions(valid_transactions))
    prev_block_hash = Chain.get_most_recent_block_hash()
    chain_state_merkle = Chain.get_state() |> Block.hash_blocks() |> MerkleTree.get_merkle_root()
    hd = Head.create_header(prev_block_hash, @difficulty, 1, chain_state_merkle, merkle_root)
    pow = Impl.pow_hashcash_algo(hd)
    Impl.insert_block(pow, valid_transactions)
  end
end
