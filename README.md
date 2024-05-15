# Account

Simple Elixir project to test the GenServer concept. 

For it, I created an Account GenServer, which holds an account balance and exposes deposit, withdraw, and transfer money to other accounts operations.

### Example

You can test using `iex -S mix` and then play with some commands, for example:

```elixir
{:ok, acc1} = Account.start_link(1000)
{:ok, acc2} = Account.start_link(500)

Account.deposit(acc1, 250)
Account.deposit(acc2, 100)

Account.withdraw(acc1, 50)
Account.withdraw(acc2, 100)

Account.transfer(acc1, acc2, 75)

Account.balance(acc1)
Account.balance(acc2)
```

## Test

Run `mix test`