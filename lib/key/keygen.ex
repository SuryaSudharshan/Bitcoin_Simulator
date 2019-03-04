defmodule Blockchain.Key.Keygen do
  def get_public_key(private_key) do
    {:ok, private_key} = Base.decode16(private_key)
    {public_key, _} = :crypto.generate_key(:ecdh, :secp256k1, private_key)
    public_key |> Base.encode16()
  end
end
