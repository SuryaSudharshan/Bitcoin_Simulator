defmodule Blockchain.Core.Block do
  alias Blockchain.Core.{
    Head,
    Transaction
  }

  import ShorterMaps

  defstruct [
    :header,
    :transaction_list
  ]

  def create_block(header, transaction_list) do
    ~M{%__MODULE__ header, transaction_list}
  end

  def genesis_block do
    ~M{%__MODULE__ header: Head.genesis_header(), transaction_list: Transaction.genesis_block_transactions()}
  end

  def hash_block(block) do
    Head.hash_header(block.header)
  end

  def hash_blocks(blocks) do
    for block <- blocks, do: hash_block(block)
  end
end
