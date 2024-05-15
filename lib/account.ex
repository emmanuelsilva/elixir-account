defmodule Account do
  use GenServer

  def start_link(initial_balance, read_only \\ false) do
    GenServer.start_link(__MODULE__, {initial_balance, read_only})
  end

  def balance(pid) do
    GenServer.call(pid, :balance)
  end

  def deposit(pid, amount) do
    GenServer.call(pid, {:deposit, amount})
  end

  def withdraw(pid, amount) do
    GenServer.call(pid, {:withdraw, amount})
  end

  def transfer(from_pid, to_pid, amount) do
    case withdraw(from_pid, amount) do
      :ok -> try_deposit_or_compensate(from_pid, to_pid, amount)
      {:error, reason} -> {:error, reason}
    end
  end

  defp try_deposit_or_compensate(from_pid, to_pid, amount) do
    case deposit(to_pid, amount) do
      :ok ->
        :ok

      {:error, reason} ->
        deposit(from_pid, amount)
        {:error, reason}
    end
  end

  def init({initial_balance, read_only}) do
    {:ok, %{balance: initial_balance, read_only: read_only}}
  end

  def handle_call(:balance, _from, state) do
    {:reply, state.balance, state}
  end

  def handle_call({:withdraw, _amount}, _from, %{read_only: true} = state) do
    {:reply, {:error, :read_only_account}, state}
  end

  def handle_call({:withdraw, amount}, _from, state) when state.balance >= amount do
    new_state = %{state | balance: state.balance - amount}
    {:reply, :ok, new_state}
  end

  def handle_call({:withdraw, _amount}, _from, state) do
    {:reply, {:error, :insufficient_funds}, state}
  end

  def handle_call({:deposit, _amount}, _from, %{read_only: true} = state) do
    {:reply, {:error, :read_only_account}, state}
  end

  def handle_call({:deposit, amount}, _from, state) do
    new_state = %{state | balance: state.balance + amount}
    {:reply, :ok, new_state}
  end
end
