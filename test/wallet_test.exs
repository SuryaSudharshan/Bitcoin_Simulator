defmodule WalletTest do
  use ExUnit.Case

  alias Blockchain.
  {
    Miner,
    Wallet,
    Chain
  }

  alias Blockchain.Key.{
    KeyServer
  }

  test "check amount post transaction" do
    Chain.fetch_initial_chain()
    public_key1 = KeyServer.get_public_key1()
    public_key2 = KeyServer.get_public_key2()
    Wallet.send_coins(public_key1, public_key2, 15, KeyServer.get_private_key1())
    Miner.Server.mine_block()
    assert Wallet.check_amount(public_key2) == 40
    assert Wallet.check_amount(public_key1) == 10
  end

  test "send invalid value of coins" do
    # IO.puts("Sending an invalid number of coins,for eg: 19.28")
    Chain.fetch_initial_chain()
    public_key1 = KeyServer.get_public_key1()
    # IO.puts("Initial balance of sender:")
    # IO.inspect(Wallet.check_amount(public_key1))
    public_key2 = KeyServer.get_public_key2()
    # IO.puts("Initial balance of receiver:")
    # IO.inspect(Wallet.check_amount(public_key2))
    Wallet.send_coins(public_key1, public_key2, 19.28, KeyServer.get_private_key1())
    Miner.Server.mine_block()
    # IO.puts("Beginning Mining")
    # IO.puts("Final balance of sender:")
    # IO.inspect(Wallet.check_amount(public_key1))
    # IO.puts("Final balance of receiver:")
    # IO.inspect(Wallet.check_amount(public_key2))
    assert Wallet.check_amount(public_key1) == 25
    assert Wallet.check_amount(public_key2) == 25
  end

  test "send coins more than amount" do
    Chain.fetch_initial_chain()

    # IO.puts("Sending an amount greater than present in the wallet. For eg. Send 20 first then Send 20 again, with an initial balance of only 25")
    public_key1 = KeyServer.get_public_key1()
    public_key2 = KeyServer.get_public_key2()
    # IO.puts("Initial balance of sender:")
    # IO.inspect(Wallet.check_amount(public_key1))
    # IO.puts("Initial balance of receiver:")
    # IO.inspect(Wallet.check_amount(public_key2))
    # IO.puts("Transaction 1 of sender sending receiver 20")
    Wallet.send_coins(public_key1, public_key2, 20, KeyServer.get_private_key1())
    # IO.puts("Transaction 2 of sender sending receiver 20 again")
    Wallet.send_coins(public_key1, public_key2, 20, KeyServer.get_private_key1())
    Miner.Server.mine_block()
    # IO.puts("Beginning Mining")
    # IO.puts("Final balance of sender:")
    # IO.inspect(Wallet.check_amount(public_key1))
    # IO.puts("Final balance of receiver:")
    # IO.inspect(Wallet.check_amount(public_key2))
    assert Wallet.check_amount(public_key1) == 5
    assert Wallet.check_amount(public_key2) == 45
  end
end
