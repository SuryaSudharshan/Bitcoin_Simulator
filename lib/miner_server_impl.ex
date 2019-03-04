defmodule Blockchain.Miner.Server.Impl do
  alias Blockchain.{
    TransactionsPool,
    Chain,
    MerkleTree
  }

  alias Blockchain.Core.{
    Head,
    Block,
    Transaction
  }

  alias Blockchain.Miner.Server

  @difficulty 4

  def mine(%{miner: :running}) do
    valid_transactions =
      TransactionsPool.get_all_transactions_and_flush_pool() |> Server.check_transactions()

    merkle_root = MerkleTree.get_merkle_root(Transaction.hash_transactions(valid_transactions))
    prev_block_hash = Chain.get_most_recent_block_hash()
    chain_state_merkle = Chain.get_state() |> Block.hash_blocks() |> MerkleTree.get_merkle_root()
    hd = Head.create_header(prev_block_hash, @difficulty, 1, chain_state_merkle, merkle_root)
    pow = pow_hashcash_algo(hd)
    insert_block(pow, valid_transactions)
    Process.send_after(self(), :work, 2000)
  end

  def mine(%{miner: :stopped} = state) do
    state
  end

  def pow_hashcash_algo(hd) do
    hash = Head.hash_header(hd)

    if Regex.match?(~r/^[0]{#{hd.diff_target}}.*$/, hash) do
      hd
    else
      pow_hashcash_algo(%{hd | nonce: hd.nonce + 1})
    end
  end

  def insert_block(hd, transactions) do
    bl = Block.create_block(hd, transactions)
    Chain.put_block(bl)
  end
end
