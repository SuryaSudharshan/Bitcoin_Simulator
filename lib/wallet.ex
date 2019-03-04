defmodule Blockchain.Wallet do
  alias Blockchain.{
    Chain,
    Core.Transaction,
    TransactionsPool
  }

  def send_coins(origin_account, destination_account, amount, private_key) do
    transaction = Transaction.create_transaction(origin_account, destination_account, amount)

    if transaction != {:error, :incorrect_transaction} do
      signed_transaction = Transaction.sign_transaction(transaction, private_key)
      TransactionsPool.add_transaction(signed_transaction)
    else
      transaction
    end
  end

  def check_amount(public_key) do
    chain = Chain.get_state()
    transaction_list = for transaction <- chain, do: transaction.transaction_list

    Enum.reduce(List.flatten(transaction_list), 0, fn transaction, account ->
      account =
        if transaction.destination_account == public_key do
          account = account + transaction.amount
        else
          if transaction.origin_account == public_key do
            account = account - transaction.amount
          else
            account
          end
        end
    end)
  end
end
