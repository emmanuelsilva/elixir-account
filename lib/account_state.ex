defmodule AccountState do
  @moduledoc """
  A struct representing an account state.
  """
  defstruct balance: 0.0,
            read_only?: false

  @typedoc "A struct representing an account state."
  @type t() :: %__MODULE__{
          balance: float(),
          read_only?: boolean()
        }
end
