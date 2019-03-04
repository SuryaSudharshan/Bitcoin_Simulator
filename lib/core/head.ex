defmodule Blockchain.Core.Head do
  alias Blockchain.{
    SecretManager
  }

  import ShorterMaps

  defstruct [
    :prev_block,
    :diff_target,
    :nonce,
    :chain_state_merkle,
    :transactions_merkle
  ]

  def create_header(prev_block, diff_target, nonce, chain_state_merkle, transactions_merkle) do
    ~M{%__MODULE__ prev_block, diff_target, nonce, chain_state_merkle, transactions_merkle}
  end

  def genesis_header do
    ~M{%__MODULE__ prev_block: "", diff_target: 1, nonce: 222, chain_state_merkle: "", transactions_merkle: ""}
  end

  def hash_header(header) do
    data = header.prev_block <> to_string(header.nonce) <> header.transactions_merkle
    SecretManager.hash(data)
  end
end
