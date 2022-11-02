defmodule Backend.Accounts.Users.List do
  @moduledoc """
  List all an user from the database.
  """
  import Ecto.Query, warn: false
  alias Backend.Accounts.User
  alias Backend.Repo

  @doc """
  List all an user from the database.
  """
  def call(params) do
    per_page = String.to_integer(params["per_page"] || "10")
    offset = String.to_integer(params["offset"] || "0")

    users =
      User
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()

    users
  end
end
