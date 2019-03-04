defmodule Blockchain.SecretManager do
  def sign(data, key) do
    :crypto.sign(:ecdsa, :sha256, data, [key, :secp256k1]) |> Base.encode16()
  end

  def verify(hash, sign, public_key) do
    :crypto.verify(:ecdsa, :sha256, hash, sign, [public_key, :secp256k1])
  end

  def hash(data) do
    :crypto.hash(:sha256, data) |> Base.encode16()
  end

  def sign_transaction_data(key, data) do
    {:ok, key} = Base.decode16(key)
    sign(data, key)
  end
end
