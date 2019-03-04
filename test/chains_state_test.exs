defmodule ChainStateTest do
  use ExUnit.Case

  alias Blockchain

  alias Blockchain.Core.{
    Block,
    Transaction
  }

  alias Blockchain.{
    Miner,
    Wallet,
    Chain,
    TransactionsPool,
    MerkleTree
  }

  alias Blockchain.Key.{
    KeyServer
  }

  test "block added to chain" do
    # IO.puts("After mining the most recent block should be the root of the Merkle tree and also added as the last block in the chain")
    state = Chain.get_state() |> Block.hash_blocks()
    Miner.Server.mine_block()
    get_most_recent_block = Chain.get_most_recent_block()
    # IO.puts("Last block of the chain")
    # IO.inspect(get_most_recent_block)
    # IO.puts("Root of Merkle Tree:")
    # IO.inspect(MerkleTree.get_merkle_root(state))
    # IO.puts("After mining,the block is added to the chain. The most recent block is the root of the Merkle tree and also the last block in the chain")
    assert get_most_recent_block.header.chain_state_merkle == MerkleTree.get_merkle_root(state)
  end

  test "transaction added to chain" do
    Chain.fetch_initial_chain()
    public_key1 = KeyServer.get_public_key1()

    Wallet.send_coins(
      KeyServer.get_miner_public_key(),
      public_key1,
      5,
      KeyServer.get_miner_private_key()
    )

    [transaction] = TransactionsPool.get_all_transactions()
    # IO.puts("List of unprocessed transactions")
    # IO.inspect(transaction)
    # IO.puts("Beginning Mining")
    Miner.Server.mine_block()
    ch_state = Chain.get_state()
    # IO.inspect(ch_state)
    # IO.puts("Last block contains the unprocessed transaction along with the reward for mining assigned to the block that mined it.")
    transactions = for bl <- ch_state, do: bl.transaction_list
    hashed_transactions = Transaction.hash_transactions(List.flatten(transactions))
    hashed_transaction = Transaction.hash_transaction(transaction)
    assert Enum.member?(hashed_transactions, hashed_transaction)
  end

  test "transaction not added to chainstate" do
    Chain.fetch_initial_chain()
    public_key1 = KeyServer.get_public_key1()

    Wallet.send_coins(
      KeyServer.get_miner_public_key(),
      public_key1,
      125,
      KeyServer.get_miner_private_key()
    )

    [transaction] = TransactionsPool.get_all_transactions()
    # IO.puts("List of unprocessed transactions")
    # IO.inspect(transaction)
    # IO.puts("Beginning Mining")
    Miner.Server.mine_block()
    ch_state = Chain.get_state()
    # IO.puts("State of the blockchain")
    # IO.inspect(ch_state)
    # IO.puts("Transaction not added as it was not validated")
    transactions = for bl <- ch_state, do: bl.transaction_list
    hashed_transactions = Transaction.hash_transactions(List.flatten(transactions))
    hashed_transaction = Transaction.hash_transaction(transaction)
    refute Enum.member?(hashed_transactions, hashed_transaction)
  end
end
