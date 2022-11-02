defmodule Backend.Accounts.Users.UpdateTest do
  use Backend.DataCase, async: true

  import Mox
  import Backend.Factory

  alias Backend.Accounts.{Address, User}
  alias Backend.Accounts.Users.Update
  alias Backend.Error
  alias Backend.ViaCep.ClientMock

  describe "call/1" do
    setup do
      user = insert(:user)

      {:ok, user: user}
    end

    test "When all parameters are valid" do
      params = build(:user_params, %{"id" => "af01c441-d16f-45dc-aa61-2dee8d72824f"})

      expect(ClientMock, :fetch_address, fn _postal_code ->
        {:ok, build(:postal_code_info)}
      end)

      response = Update.call(params)

      assert {:ok, %User{id: _id, name: "Mario Cassiano", cpf: "12345678901"}} = response
    end

    test "When there are invalid parameters" do
      params =
        build(:user_params, %{
          "id" => "af01c441-d16f-45dc-aa61-2dee8d72824f",
          "name" => "",
          "cpf" => "1",
          "address" => %{"postal_code" => ""}
        })

      response = Update.call(params)

      expected_response = %{
        name: ["can't be blank"],
        address: %{postal_code: ["can't be blank"]}
      }

      assert {:error, %Error{result: changeset, status: :bad_request}} = response

      assert errors_on(changeset) == expected_response
    end

    test "When the postal code is invalid and needs more validations with result is ok" do
      params =
        build(:user_params, %{
          "id" => "af01c441-d16f-45dc-aa61-2dee8d72824f",
          "address" => %{
            "postal_code" => "89031599",
            "street" => "Praça da Sé",
            "complement" => "lado ímpar",
            "neighborhood" => "Sé",
            "city" => "São Paulo",
            "state" => "SP"
          }
        })

      expect(ClientMock, :fetch_address, fn _postal_code ->
        {:needs_more_validation, Error.build(:not_found, "CEP not found!")}
      end)

      response = Update.call(params)

      assert {:ok,
              %User{
                id: _id,
                name: "Mario Cassiano",
                cpf: "12345678901",
                address: %Address{
                  city: "São Paulo",
                  complement: "lado ímpar",
                  neighborhood: "Sé",
                  number: nil,
                  postal_code: "89031599",
                  state: "SP",
                  street: "Praça da Sé"
                }
              }} = response
    end

    test "When the postal code is invalid and needs more validations with error" do
      params =
        build(:user_params, %{
          "id" => "af01c441-d16f-45dc-aa61-2dee8d72824f",
          "address" => %{
            "city" => "",
            "complement" => "",
            "neighborhood" => "",
            "number" => "",
            "postal_code" => "89031599",
            "state" => "",
            "street" => ""
          }
        })

      expect(ClientMock, :fetch_address, fn _postal_code ->
        {:needs_more_validation, Error.build(:bad_request, "Invalid CEP!")}
      end)

      response = Update.call(params)

      expected_response = %{
        street: ["can't be blank"],
        neighborhood: ["can't be blank"],
        city: ["can't be blank"],
        state: ["can't be blank"]
      }

      assert {:error, %Error{result: changeset, status: :bad_request}} = response

      assert errors_on(changeset) == expected_response
    end

    test "When the user not found" do
      params =
        build(:user_params, %{
          "id" => "1c6ab9de-44d7-4590-8639-57d7cc60df4a"
        })

      response = Update.call(params)

      assert {:error, %Error{result: "User not found", status: :not_found}} = response
    end
  end
end
