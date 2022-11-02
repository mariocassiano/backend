defmodule Backend.Accounts.Users.Get do
  @moduledoc """
  Gets the users in the database.
  """
  alias Backend.Accounts.User
  alias Backend.{Error, Repo}

  @doc """
  Gets an user by id in the database.
  """
  def by_id(id) do
    case Repo.get(User, id) do
      nil -> {:error, Error.build_user_not_found()}
      user_schema -> {:ok, user_schema}
    end
  end
end
