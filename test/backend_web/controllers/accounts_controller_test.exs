defmodule BackendWeb.AccountsControllerTest do
  use BackendWeb.ConnCase, async: true

  import Mox
  import Backend.Factory

  alias Backend.Error
  alias Backend.ViaCep.ClientMock

  describe "list/1" do
    setup %{conn: conn} do
      insert(:user, id: "4999712b-d80d-4cb0-9641-3bd53d295cfe", cpf: "09876543210")
      user = insert(:user)

      {:ok, conn: conn, user: user}
    end

    test "list all users", %{conn: conn} do
      params = %{
        "per_page" => "1",
        "offset" => "1"
      }

      response =
        conn
        |> get(Routes.accounts_path(conn, :index, params))
        |> json_response(:ok)

      assert %{
               "users" => [
                 %{
                   "address" => %{
                     "city" => "São Paulo",
                     "complement" => "lado ímpar",
                     "neighborhood" => "Sé",
                     "number" => 1846,
                     "postal_code" => "01001000",
                     "state" => "SP",
                     "street" => "Praça da Sé"
                   },
                   "cpf" => "12345678901",
                   "id" => _id,
                   "name" => "Mario Cassiano"
                 }
               ]
             } = response
    end
  end

  describe "create/2" do
    test "When all parameters are valid, creates the user", %{conn: conn} do
      params = build(:user_params)

      expect(ClientMock, :fetch_address, fn _postal_code ->
        {:ok, build(:postal_code_info)}
      end)

      response =
        conn
        |> post(Routes.accounts_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "user" => %{
                 "address" => %{
                   "city" => "São Paulo",
                   "complement" => "lado ímpar",
                   "neighborhood" => "Sé",
                   "number" => 1846,
                   "postal_code" => "01001000",
                   "state" => "SP",
                   "street" => "Praça da Sé"
                 },
                 "cpf" => "12345678901",
                 "id" => _id,
                 "name" => "Mario Cassiano"
               }
             } = response
    end

    test "When there is some error, returns the error", %{conn: conn} do
      params = %{"name" => "", "cpf" => "1", "address" => %{"postal_code" => ""}}

      response =
        conn
        |> post(Routes.accounts_path(conn, :create, params))
        |> json_response(:bad_request)

      expected_response = %{
        "message" => %{
          "cpf" => ["has invalid format", "should be 11 character(s)"],
          "address" => %{"postal_code" => ["can't be blank"]},
          "name" => ["can't be blank"]
        }
      }

      assert response == expected_response
    end

    test "When the postal code is invalid and needs more validations with result is ok", %{
      conn: conn
    } do
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

      response =
        conn
        |> post(Routes.accounts_path(conn, :create, params))
        |> json_response(:created)

      assert %{
               "user" => %{
                 "address" => %{
                   "postal_code" => "89031599",
                   "street" => "Praça da Sé",
                   "complement" => "lado ímpar",
                   "neighborhood" => "Sé",
                   "city" => "São Paulo",
                   "state" => "SP"
                 },
                 "cpf" => "12345678901",
                 "id" => _id,
                 "name" => "Mario Cassiano"
               }
             } = response
    end

    test "When the postal code is invalid and needs more validations with result is an error", %{
      conn: conn
    } do
      params =
        build(:user_params, %{
          "address" => %{
            "postal_code" => "89031599",
            "street" => "",
            "neighborhood" => "",
            "city" => "",
            "state" => ""
          }
        })

      expect(ClientMock, :fetch_address, fn _postal_code ->
        {:needs_more_validation, Error.build(:bad_request, "Invalid CEP!")}
      end)

      response =
        conn
        |> post(Routes.accounts_path(conn, :create, params))
        |> json_response(:bad_request)

      expected_response = %{
        "message" => %{
          "city" => ["can't be blank"],
          "neighborhood" => ["can't be blank"],
          "state" => ["can't be blank"],
          "street" => ["can't be blank"]
        }
      }

      assert response == expected_response
    end
  end

  describe "get/2" do
    setup %{conn: conn} do
      user = insert(:user)

      {:ok, conn: conn, user: user}
    end

    test "When there is a user with the given id", %{conn: conn} do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824f"

      response =
        conn
        |> get(Routes.accounts_path(conn, :show, id))
        |> json_response(:ok)

      assert %{
               "user" => %{
                 "address" => %{
                   "city" => "São Paulo",
                   "complement" => "lado ímpar",
                   "neighborhood" => "Sé",
                   "number" => 1846,
                   "postal_code" => "01001000",
                   "state" => "SP",
                   "street" => "Praça da Sé"
                 },
                 "cpf" => "12345678901",
                 "id" => _id,
                 "name" => "Mario Cassiano"
               }
             } = response
    end

    test "When there is a user with the given invalid ID", %{conn: conn} do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824x"

      response =
        conn
        |> get(Routes.accounts_path(conn, :show, id))
        |> json_response(:bad_request)

      assert response == %{"message" => "Invalid UUID"}
    end

    test "When there is a user with ID not found", %{conn: conn} do
      id = "721ad676-6862-4141-ac72-700b11730606"

      response =
        conn
        |> get(Routes.accounts_path(conn, :show, id))
        |> json_response(:not_found)

      assert response == %{"message" => "User not found"}
    end
  end

  describe "update/2" do
    setup %{conn: conn} do
      user = insert(:user)

      {:ok, conn: conn, user: user}
    end

    test "When all parameters are valid, updates the user", %{conn: conn} do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824f"
      params = build(:user_params, %{"name" => "Cassiano Mario"})

      expect(ClientMock, :fetch_address, fn _postal_code ->
        {:ok, build(:postal_code_info)}
      end)

      response =
        conn
        |> put(Routes.accounts_path(conn, :update, id), params)
        |> json_response(:ok)

      assert %{
               "user" => %{
                 "address" => %{
                   "city" => "São Paulo",
                   "complement" => "lado ímpar",
                   "neighborhood" => "Sé",
                   "number" => 1846,
                   "postal_code" => "01001000",
                   "state" => "SP",
                   "street" => "Praça da Sé"
                 },
                 "cpf" => "12345678901",
                 "id" => _id,
                 "name" => "Cassiano Mario"
               }
             } = response
    end

    test "When there is a user with the given invalid ID", %{conn: conn} do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824x"
      params = build(:user_params)

      response =
        conn
        |> put(Routes.accounts_path(conn, :update, id), params)
        |> json_response(:bad_request)

      assert response == %{"message" => "Invalid UUID"}
    end

    test "When there is a user with ID not found", %{conn: conn} do
      id = "721ad676-6862-4141-ac72-700b11730606"
      params = build(:user_params)

      response =
        conn
        |> put(Routes.accounts_path(conn, :update, id), params)
        |> json_response(:not_found)

      assert response == %{"message" => "User not found"}
    end

    test "When the postal code is invalid and needs more validations with result is ok", %{
      conn: conn
    } do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824f"

      params =
        build(:user_params, %{
          "name" => "Cassiano Mario",
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

      response =
        conn
        |> put(Routes.accounts_path(conn, :update, id), params)
        |> json_response(:ok)

      assert %{
               "user" => %{
                 "address" => %{
                   "city" => "São Paulo",
                   "complement" => "lado ímpar",
                   "neighborhood" => "Sé",
                   "postal_code" => "89031599",
                   "state" => "SP",
                   "street" => "Praça da Sé"
                 },
                 "cpf" => "12345678901",
                 "id" => _id,
                 "name" => "Cassiano Mario"
               }
             } = response
    end

    test "When the postal code is invalid and needs more validations with error", %{
      conn: conn
    } do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824f"

      params =
        build(:user_params, %{
          "name" => "Cassiano Mario",
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

      response =
        conn
        |> put(Routes.accounts_path(conn, :update, id), params)
        |> json_response(:bad_request)

      expected_response = %{
        "message" => %{
          "city" => ["can't be blank"],
          "neighborhood" => ["can't be blank"],
          "state" => ["can't be blank"],
          "street" => ["can't be blank"]
        }
      }

      assert expected_response == response
    end
  end

  describe "delete/2" do
    setup %{conn: conn} do
      user = insert(:user)

      {:ok, conn: conn, user: user}
    end

    test "When there is a user with the given id, delete the user", %{conn: conn} do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824f"

      response =
        conn
        |> delete(Routes.accounts_path(conn, :delete, id))
        |> response(:no_content)

      assert response == ""
    end

    test "When there is a user with the given invalid ID", %{conn: conn} do
      id = "af01c441-d16f-45dc-aa61-2dee8d72824x"

      response =
        conn
        |> delete(Routes.accounts_path(conn, :delete, id))
        |> json_response(:bad_request)

      assert response == %{"message" => "Invalid UUID"}
    end

    test "When there is a user with ID not found", %{conn: conn} do
      id = "721ad676-6862-4141-ac72-700b11730606"

      response =
        conn
        |> delete(Routes.accounts_path(conn, :delete, id))
        |> json_response(:not_found)

      assert response == %{"message" => "User not found"}
    end
  end
end
