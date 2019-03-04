defmodule Blockchain.Key.KeyServer do
  alias Blockchain.Key.Keygen
  alias Blockchain.Key.Keys

  def get_miner_private_key do
    Keys.get_pvt_miner_key()
  end

  def get_miner_public_key do
    Keygen.get_public_key(get_miner_private_key())
  end

  def get_private_key1 do
    Keys.get_pvt_key1()
  end

  def get_public_key1 do
    Keygen.get_public_key(get_private_key1())
  end

  def get_private_key2 do
    Keys.get_pvt_key2()
  end

  def get_public_key2 do
    Keygen.get_public_key(get_private_key2())
  end

  def get_private_key3 do
    Keys.get_pvt_key3()
  end

  def get_public_key3 do
    Keygen.get_public_key(get_private_key3())
  end
end
