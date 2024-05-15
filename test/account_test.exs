defmodule AccountTest do
  use ExUnit.Case
  alias Account
  doctest Account

  @initial_balance 1000

  setup do
    {:ok, account} = Account.start_link(@initial_balance, false)
    {:ok, account_read_only} = Account.start_link(@initial_balance, true)
    {:ok, account: account, account_read_only: account_read_only}
  end

  describe "Balance" do
    test "returns the current balance for a given account", %{account: account} do
      assert Account.balance(account) == @initial_balance
    end

    test "returns the current balance for a given read-only account", %{
      account: account_read_only
    } do
      assert Account.balance(account_read_only) == @initial_balance
    end
  end

  describe "Deposit" do
    test "succeeds when depositing into a writable account", %{account: account} do
      amount = 500
      Account.deposit(account, amount)
      assert Account.balance(account) == @initial_balance + amount
    end

    test "fails when trying to deposit into a read-only account", %{
      account_read_only: account_read_only
    } do
      amount = 500
      assert Account.deposit(account_read_only, amount) == {:error, :read_only_account}
      assert Account.balance(account_read_only) == @initial_balance
    end
  end

  describe "Withdraw" do
    test "succeeds when there is enough balance", %{account: account} do
      amount = 200
      assert Account.withdraw(account, amount) == :ok
      assert Account.balance(account) == @initial_balance - amount
    end

    test "fails when there is not enough balance", %{account: account} do
      exceeded_amount = @initial_balance + 100
      assert Account.withdraw(account, exceeded_amount) == {:error, :insufficient_funds}
      assert Account.balance(account) == @initial_balance
    end

    test "fails when trying to withdraw from a read-only account", %{
      account_read_only: account_read_only
    } do
      amount = 200
      assert Account.withdraw(account_read_only, amount) == {:error, :read_only_account}
      assert Account.balance(account_read_only) == @initial_balance
    end
  end

  describe "Transfer" do
    setup do
      {:ok, from_account} = Account.start_link(@initial_balance)
      {:ok, destination_account} = Account.start_link(@initial_balance)
      {:ok, destination_read_only_account} = Account.start_link(@initial_balance, true)

      {:ok,
       from_account: from_account,
       destination_account: destination_account,
       destination_read_only_account: destination_read_only_account}
    end

    test "succeeds when there is enough balance in the from account", %{
      from_account: from_account,
      destination_account: destination_account
    } do
      amount = @initial_balance - 300
      assert Account.transfer(from_account, destination_account, amount) == :ok
      assert Account.balance(from_account) == @initial_balance - amount
      assert Account.balance(destination_account) == @initial_balance + amount
    end

    test "fails when there is not enough balance in the from account", %{
      from_account: from_account,
      destination_account: destination_account
    } do
      exceeded_amount = @initial_balance + 350

      assert Account.transfer(from_account, destination_account, exceeded_amount) ==
               {:error, :insufficient_funds}

      assert Account.balance(from_account) == @initial_balance
      assert Account.balance(destination_account) == @initial_balance
    end

    test "fails when trying to transfer to a read-only account", %{
      from_account: from_account,
      destination_read_only_account: destination_read_only_account
    } do
      amount = @initial_balance - 300

      assert Account.transfer(from_account, destination_read_only_account, amount) ==
               {:error, :read_only_account}

      assert Account.balance(from_account) == @initial_balance
      assert Account.balance(destination_read_only_account) == @initial_balance
    end
  end
end
