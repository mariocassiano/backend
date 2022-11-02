defmodule Backend.Accounts.Users.Create do
  @moduledoc """
  Insert an user into the database.
  """
  alias Backend.Accounts
  alias Backend.Accounts.{Address, User}
  alias Backend.{Error, Repo}

  @doc """
  Insert an user into the database.
  """
  def call(%{} = params) do
    changeset = User.changeset(params)

    with {:ok, %User{}} <- User.build(changeset),
         {:ok, %{} = postal_code_info} <- Accounts.load_address(params),
         params = Address.update(params, postal_code_info),
         changeset = User.changeset(params),
         {:ok, %User{}} = user <- Repo.insert(changeset) do
      user
    else
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end

  def call(_anything), do: {:error, "Enter the data in a map format"}
end
