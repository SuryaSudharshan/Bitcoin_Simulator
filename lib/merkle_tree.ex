defmodule Blockchain.MerkleTree do
  def get_merkle_root(transactions) do
    grouped_transactions = group_transactions(transactions)
    merkle_tree = calculate_map(to_map(grouped_transactions))
    [merkle_root] = Map.keys(merkle_tree)
    merkle_root
  end

  def get_merkle_tree(transactions) do
    grouped_transactions = group_transactions(transactions)
    calculate_map(to_map(grouped_transactions))
  end

  defp group_transactions(transactions) do
    if rem(length(transactions), 2) != 0 do
      transactions = transactions ++ [List.last(transactions)]
      Enum.chunk_every(transactions, 2)
    else
      Enum.chunk_every(transactions, 2)
    end
  end

  defp to_map(grouped_transactions) do
    for transaction_pair <- grouped_transactions,
        into: %{},
        do: {hash_keys(transaction_pair), transaction_pair}
  end

  defp hash_keys(transaction_pair) do
    joined_pair = Enum.join(transaction_pair)
    hashed_pair = :crypto.hash(:sha256, joined_pair)
    hashed_pair |> Base.encode16()
  end

  defp calculate_map(map) do
    keys = Map.keys(map)

    cond do
      length(keys) == 1 ->
        map

      length(keys) |> rem(2) != 0 ->
        last_key = List.last(keys)
        calculate_map(Map.put(map, last_key <> "1", []))

      length(keys) |> rem(2) == 0 ->
        keys = Enum.chunk_every(keys, 2)

        map =
          for k <- keys,
              into: %{},
              do:
                {hash_keys(k),
                 for(
                   map_key <- k,
                   into: %{},
                   do: {map_key, map[map_key]}
                 )}

        calculate_map(map)

      true ->
        map
    end
  end
end
