defmodule Blockchain.ValidateTransaction do
  alias Blockchain.SecretManager

  def is_valid(hash, signature, public_key) do
    if public_key == "" do
      true
    else
      {:ok, public_key} = Base.decode16(public_key)
      {:ok, signature} = Base.decode16(signature)
      SecretManager.verify(hash, signature, public_key)
    end
  end
end
