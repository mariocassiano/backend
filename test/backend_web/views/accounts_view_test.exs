defmodule BackendWeb.AccountsViewTest do
  use BackendWeb.ConnCase, async: true

  import Phoenix.View
  import Backend.Factory

  alias Backend.Accounts.{Address, User}
  alias BackendWeb.AccountsView

  test "renders index.json" do
    user =
      build(:user_params, %{
        "id" => "4999712b-d80d-4cb0-9641-3bd53d295cfe",
        "cpf" => "09876543210"
      })

    users = [build(:user_params), user]

    response = render(AccountsView, "index.json", users: users)

    assert %{
             users: [
               %{
                 "address" => %{
                   "city" => "São Paulo",
                   "complement" => "lado ímpar",
                   "neighborhood" => "Sé",
                   "number" => "1846",
                   "postal_code" => "01001000",
                   "state" => "SP",
                   "street" => "Praça da Sé"
                 },
                 "cpf" => "12345678901",
                 "name" => "Mario Cassiano"
               },
               %{
                 "address" => %{
                   "city" => "São Paulo",
                   "complement" => "lado ímpar",
                   "neighborhood" => "Sé",
                   "number" => "1846",
                   "postal_code" => "01001000",
                   "state" => "SP",
                   "street" => "Praça da Sé"
                 },
                 "cpf" => "09876543210",
                 "name" => "Mario Cassiano"
               }
             ]
           } = response
  end

  test "renders create.json" do
    user = build(:user)

    response = render(AccountsView, "create.json", user: user)

    assert %{
             user: %User{
               id: "af01c441-d16f-45dc-aa61-2dee8d72824f",
               name: "Mario Cassiano",
               cpf: "12345678901",
               address: %Address{
                 postal_code: "01001000",
                 street: "Praça da Sé",
                 complement: "lado ímpar",
                 number: "1846",
                 neighborhood: "Sé",
                 city: "São Paulo",
                 state: "SP"
               },
               inserted_at: nil,
               updated_at: nil
             }
           } = response
  end

  test "renders user.json" do
    user = build(:user)

    response = render(AccountsView, "user.json", user: user)

    assert %{
             user: %User{
               id: "af01c441-d16f-45dc-aa61-2dee8d72824f",
               name: "Mario Cassiano",
               cpf: "12345678901",
               address: %Address{
                 postal_code: "01001000",
                 street: "Praça da Sé",
                 complement: "lado ímpar",
                 number: "1846",
                 neighborhood: "Sé",
                 city: "São Paulo",
                 state: "SP"
               },
               inserted_at: nil,
               updated_at: nil
             }
           } = response
  end
end
