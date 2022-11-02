defmodule Backend.Accounts do
  @moduledoc """
  Backend keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Backend.Accounts.Users.Create, as: UserCreate
  alias Backend.Accounts.Users.Delete, as: UserDelete
  alias Backend.Accounts.Users.Get, as: UserGet
  alias Backend.Accounts.Users.List, as: UserList
  alias Backend.Accounts.Users.Update, as: UserUpdate

  alias Backend.Accounts.Address.LoadAddress, as: AddressLoad

  # Users
  defdelegate create_user(params), to: UserCreate, as: :call
  defdelegate get_user_by_id(id), to: UserGet, as: :by_id
  defdelegate list_users(params), to: UserList, as: :call
  defdelegate delete_user(id), to: UserDelete, as: :call
  defdelegate update_user(params), to: UserUpdate, as: :call

  # Address
  defdelegate load_address(params), to: AddressLoad, as: :call
end
