defmodule Backend.Accounts.Users.CreateTest do
  use Backend.DataCase, async: true

  import Mox
  import Backend.Factory

  alias Backend.Accounts.{Address, User}
  alias Backend.Accounts.Users.Create
  alias Backend.Error
  alias Backend.ViaCep.ClientMock

  describe "call/1" do
    test "When all parameters are valid" do
      params = build(:user_params)

      expect(ClientMock, :fetch_address, fn _postal_code ->
        {:ok, build(:postal_code_info)}
      end)

      response = Create.call(params)

      assert {:ok, %User{id: _id, name: "Mario Cassiano", cpf: "12345678901"}} = response
    end

    test "When there are invalid parameters in address" do
      params =
        build(:user_params, %{"name" => "", "cpf" => "1", "address" => %{"postal_code" => ""}})

      response = Create.call(params)

      expected_response = %{
        name: ["can't be blank"],
        cpf: ["has invalid format", "should be 11 character(s)"],
        address: %{postal_code: ["can't be blank"]}
      }

      assert {:error, %Error{result: changeset, status: :bad_request}} = response

      assert errors_on(changeset) == expected_response
    end

    test "When the postal code is invalid and needs more validations with result is ok" do
      params =
        build(:user_params, %{
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

      response = Create.call(params)

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

    test "When the postal code is invalid and needs more validations with result is an error" do
      params =
        build(:user_params, %{
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

      response = Create.call(params)

      expected_response = %{
        street: ["can't be blank"],
        neighborhood: ["can't be blank"],
        city: ["can't be blank"],
        state: ["can't be blank"]
      }

      assert {:error, %Error{result: changeset, status: :bad_request}} = response

      assert errors_on(changeset) == expected_response
    end

    test "When there is an error in the data format" do
      response = Create.call("invalid data")

      assert {:error, "Enter the data in a map format"} = response
    end
  end
end
