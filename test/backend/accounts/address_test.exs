defmodule Backend.Accounts.AddressTest do
  use Backend.DataCase, async: true

  import Backend.Factory

  alias Backend.Accounts.Address
  alias Ecto.Changeset

  describe "changeset/2" do
    test "When all parameters are valid, returns a valid changeset" do
      params = build(:address_params)

      response = Address.changeset(params)

      assert %Changeset{
               changes: %{
                 city: "São Paulo",
                 complement: "lado ímpar",
                 neighborhood: "Sé",
                 number: 1846,
                 postal_code: "01001000",
                 state: "SP",
                 street: "Praça da Sé"
               },
               valid?: true
             } = response
    end

    test "When updating a changeset, returns a valid changeset with the given changes" do
      params = build(:address_params)

      update_params = %{number: "4123"}

      changeset_with_current_data = Address.changeset(params)

      response = Address.changeset(changeset_with_current_data, update_params)

      assert %Changeset{
               changes: %{
                 city: "São Paulo",
                 complement: "lado ímpar",
                 neighborhood: "Sé",
                 number: 4123,
                 postal_code: "01001000",
                 state: "SP",
                 street: "Praça da Sé"
               },
               valid?: true
             } = response
    end

    test "When there are some error, returns an invalid changeset" do
      params = build(:address_params, %{"postal_code" => ""})

      response = Address.changeset(params)

      expected_response = %{
        postal_code: ["can't be blank"]
      }

      assert errors_on(response) == expected_response
    end
  end
end
