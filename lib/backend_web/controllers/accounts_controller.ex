defmodule BackendWeb.AccountsController do
  use BackendWeb, :controller

  alias Backend.Accounts
  alias Backend.Accounts.User
  alias BackendWeb.FallbackController

  action_fallback FallbackController

  def index(conn, params) do
    users = Accounts.list_users(params)

    render(conn, "index.json", users: users)
  end

  def create(conn, params) do
    with {:ok, %User{} = user} <- Accounts.create_user(params) do
      conn
      |> put_status(:created)
      |> render("create.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Accounts.get_user_by_id(id) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user)
    end
  end

  def update(conn, params) do
    with {:ok, %User{} = user} <- Accounts.update_user(params) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %User{}} <- Accounts.delete_user(id) do
      conn
      |> put_status(:no_content)
      |> text("")
    end
  end
end
