defmodule BackendWeb.AccountsView do
  use BackendWeb, :view

  alias Backend.Accounts.User

  def render("index.json", %{users: users}) do
    %{
      users: users
    }
  end

  def render("create.json", %{user: %User{} = user}) do
    %{
      user: user
    }
  end

  def render("user.json", %{user: %User{} = user}) do
    %{
      user: user
    }
  end
end
