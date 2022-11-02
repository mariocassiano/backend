defmodule Backend.Accounts.Users.DeleteTest do
  use Backend.DataCase, async: true

  import Backend.Factory

  alias Backend.Accounts.User
  alias Backend.Accounts.Users.Delete
  alias Backend.Error

  describe "call/1" do
    setup do
      user = insert(:user)

      {:ok, user: user}
    end

    test "When there is a user with the given ID" do
      params = "af01c441-d16f-45dc-aa61-2dee8d72824f"

      response = Delete.call(params)

      assert {:ok, %User{}} = response
    end

    test "When there is a user with ID not found" do
      params = "1c6ab9de-44d7-4590-8639-57d7cc60df4a"

      response = Delete.call(params)

      assert {:error, %Error{result: "User not found", status: :not_found}} = response
    end
  end
end
