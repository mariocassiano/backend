defmodule Backend.Accounts.Users.ListTest do
  use Backend.DataCase, async: true

  import Backend.Factory

  alias Backend.Accounts.{Address, User}
  alias Backend.Accounts.Users.List

  describe "call/1" do
    setup do
      insert(:user, id: "4999712b-d80d-4cb0-9641-3bd53d295cfe", cpf: "09876543210")
      user = insert(:user)

      {:ok, user: user}
    end

    test "List all users" do
      params = %{
        "per_page" => "1",
        "offset" => "1"
      }

      response = List.call(params)

      assert [
               %User{
                 address: %Address{
                   city: "São Paulo",
                   complement: "lado ímpar",
                   neighborhood: "Sé",
                   postal_code: "01001000",
                   state: "SP",
                   street: "Praça da Sé"
                 },
                 cpf: "12345678901",
                 name: "Mario Cassiano"
               }
             ] = response
    end
  end
end
