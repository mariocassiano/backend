defmodule Backend.Accounts.Users.Update do
  @moduledoc """
  Update an user from the database.
  """
  alias Backend.Accounts
  alias Backend.Accounts.Address
  alias Backend.Accounts.User
  alias Backend.{Error, Repo}

  @doc """
  Update an user from the database.
  """
  def call(%{"id" => id} = params) do
    case Repo.get(User, id) do
      nil -> {:error, Error.build_user_not_found()}
      user_schema -> do_update(user_schema, params)
    end
  end

  defp do_update(%User{} = user, %{} = params) do
    changeset = User.changeset_to_update(user, params)

    with {:ok, %User{}} <- User.build(changeset),
         {:ok, %{} = address_info} <- Accounts.load_address(params),
         params = Address.update(params, address_info),
         changeset = user |> User.changeset_to_update(params),
         {:ok, %User{}} = user <- Repo.update(changeset) do
      user
    else
      {:error, result} -> {:error, Error.build(:bad_request, result)}
    end
  end
end
