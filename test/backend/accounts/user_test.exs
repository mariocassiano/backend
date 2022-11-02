defmodule Backend.Accounts.UserTest do
  use Backend.DataCase, async: true

  import Backend.Factory

  alias Backend.Accounts.User
  alias Ecto.Changeset

  describe "changeset/2" do
    test "When all parameters are valid, returns a valid changeset" do
      params = build(:user_params)

      response = User.changeset(params)

      assert %Changeset{changes: %{name: "Mario Cassiano"}, valid?: true} = response
    end

    test "When updating a changeset, returns a valid changeset with the given changes" do
      params = build(:user_params)

      update_params = %{name: "Cassiano Mario"}

      changeset_with_current_data = User.changeset(params)

      response = User.changeset(changeset_with_current_data, update_params)

      assert %Changeset{changes: %{name: "Cassiano Mario"}, valid?: true} = response
    end

    test "When there are some error, returns an invalid changeset" do
      params = build(:user_params, %{"name" => "", "cpf" => "123"})

      response = User.changeset(params)

      expected_response = %{
        name: ["can't be blank"],
        cpf: ["has invalid format", "should be 11 character(s)"]
      }

      assert errors_on(response) == expected_response
    end
  end
end
