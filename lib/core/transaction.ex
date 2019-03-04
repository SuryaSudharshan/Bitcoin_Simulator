defmodule Blockchain.Core.Transaction do
  alias Blockchain.{
    Core.Transaction,
    SecretManager,
    ValidateTransaction
  }

  alias Blockchain.Key.{
    KeyServer
  }

  import ShorterMaps

  defstruct [
    :id,
    :origin_account,
    :destination_account,
    :amount,
    :digital_signature
  ]

  def create_transaction(origin_account, destination_account, amount) do
    if String.length(destination_account) > 5 && amount > 0 && is_integer(amount) do
      ~M{%__MODULE__ id: generate_transaction_id(), origin_account, destination_account, amount, digital_signature: ""}
    else
      {:error, :incorrect_transaction}
    end
  end

  def coinbase_transaction(destination_account) do
    Transaction.create_transaction("", destination_account, 25)
  end

  def sign_transaction(transaction, private_key) do
    data = hash_transaction(transaction)
    %{transaction | digital_signature: SecretManager.sign_transaction_data(private_key, data)}
  end

  def is_valid?(transaction_hash, signature, pub_key) do
    ValidateTransaction.is_valid(transaction_hash, signature, pub_key)
  end

  def genesis_block_transactions do
    transaction1 = KeyServer.get_public_key1() |> coinbase_transaction()
    transaction2 = KeyServer.get_public_key2() |> coinbase_transaction()
    transaction3 = KeyServer.get_public_key3() |> coinbase_transaction()
    transaction4 = KeyServer.get_miner_public_key() |> coinbase_transaction()
    [transaction1, transaction2, transaction3, transaction4]
  end

  def generate_transaction_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end

  def hash_transaction(transaction) do
    data =
      transaction.id <>
        transaction.origin_account <>
        transaction.destination_account <> to_string(transaction.amount)

    SecretManager.hash(data)
  end

  def hash_transactions(transactions) do
    for transaction <- transactions, do: hash_transaction(transaction)
  end
end
