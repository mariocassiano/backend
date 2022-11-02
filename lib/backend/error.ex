defmodule Backend.Error do
  @keys [:status, :result]

  @enforce_keys @keys

  defstruct @keys

  @doc """
  Build error messages.
  """
  def build(status, result) do
    %__MODULE__{
      result: result,
      status: status
    }
  end

  @doc """
  Error default message for status :not_found.
  """
  def build_user_not_found, do: build(:not_found, "User not found")
end
