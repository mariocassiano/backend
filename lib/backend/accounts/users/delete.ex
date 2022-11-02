defmodule Backend.Accounts.Users.Delete do
  @moduledoc """
  Delete an user from the database.
  """

  alias Backend.Accounts.User
  alias Backend.{Error, Repo}

  @doc """
  Delete an user from the database.
  """
  def call(id) do
    case Repo.get(User, id) do
      nil -> {:error, Error.build_user_not_found()}
      user_schema -> Repo.delete(user_schema)
    end
  end
end
