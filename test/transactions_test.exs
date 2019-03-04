defmodule TransactionsTest do
  use ExUnit.Case

  alias Blockchain

  alias Blockchain.{
    Core.Transaction
  }

  alias Blockchain.{
    Miner,
    Wallet,
    Chain
  }

  alias Blockchain.Key.{
    KeyServer
  }

  import ShorterMaps

  test "add valid transaction" do
    transaction = Transaction.create_transaction("sender", "receiver", 1)

    assert transaction ==
             ~M{%Transaction id: transaction.id, origin_account: "sender", destination_account: "receiver", amount: 1, digital_signature: ""}
  end

  test "add invalid transaction" do
    assert Transaction.create_transaction("sender", "receiver", -1) ==
             {:error, :incorrect_transaction}
  end

  test "send coins with correct digital signature" do
    # IO.puts("Transaction with correct private key, valid transaction")
    Chain.fetch_initial_chain()
    public_key1 = KeyServer.get_public_key1()
    # IO.puts("Transaction Details")
    # IO.puts("Miner Public Key")
    # IO.inspect(KeyServer.get_miner_public_key())
    # IO.puts("Public Key of transaction")
    # IO.inspect(public_key1)
    # IO.puts("Amount")
    # IO.inspect(15)
    # IO.puts("Miner Private Key")
    # IO.inspect(KeyServer.get_miner_private_key())
    Wallet.send_coins(
      KeyServer.get_miner_public_key(),
      public_key1,
      15,
      KeyServer.get_miner_private_key()
    )

    # IO.puts("Beginning mining.")
    Miner.Server.mine_block()
    chain_transactions = for x <- Chain.get_state(), do: x.transaction_list
    # IO.puts("Processed Transactions")
    # IO.inspect(chain_transactions)
    filtered_transaction =
      for bl <- List.flatten(chain_transactions),
          bl.origin_account == KeyServer.get_miner_public_key(),
          bl.destination_account == public_key1,
          do: bl.id

    # IO.puts("Valid transaction filtered from the list of processed transactions.")
    # IO.inspect(filtered_transaction)
    assert filtered_transaction != []
  end

  test "send coins tokens with wrong digital signature" do
    Chain.fetch_initial_chain()
    public_key1 = KeyServer.get_public_key1()
    # IO.puts("Transaction not valid as the digital signatures do not match")
    # different private key, so sign for transaction will be invalid
    # IO.puts("Transaction Details")
    # IO.puts("Miner Public Key")
    # IO.inspect(KeyServer.get_miner_public_key())
    # IO.puts("Public Key of transaction")
    # IO.inspect(public_key1)
    # IO.puts("Amount")
    # IO.inspect(15)
    # IO.puts("Miner Private Key")
    # IO.inspect(KeyServer.get_private_key1())
    Wallet.send_coins(
      KeyServer.get_miner_public_key(),
      public_key1,
      5,
      KeyServer.get_private_key1()
    )

    # IO.puts("Beginning Mining")
    Miner.Server.mine_block()
    chain_transactions = for x <- Chain.get_state(), do: x.transaction_list
    # IO.puts("Processesd Transactions")
    # IO.inspect(chain_transactions)
    filtered_transaction =
      for transaction <- List.flatten(chain_transactions),
          transaction.origin_account == KeyServer.get_miner_public_key(),
          transaction.destination_account == public_key1,
          do: transaction.id

    # IO.puts("Transaction list filtered for our particular transaction turns out empty as it was not processed")
    # IO.inspect(filtered_transaction)
    assert filtered_transaction == []
  end
end
