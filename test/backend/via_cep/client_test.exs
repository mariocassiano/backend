defmodule Backend.ViaCep.ClientTest do
  use ExUnit.Case, async: true

  alias Backend.Error
  alias Backend.ViaCep.Client
  alias Plug.Conn

  describe "fetch_address/1" do
    setup do
      bypass = Bypass.open()

      {:ok, bypass: bypass}
    end

    test "When the postal code is valid", %{bypass: bypass} do
      postal_code = "01001000"

      url = endpoint_url(bypass.port)

      body = ~s({
        "cep": "01001000",
        "logradouro": "Praça da Sé",
        "complemento": "lado ímpar",
        "bairro": "Sé",
        "localidade": "São Paulo",
        "uf": "SP",
        "ibge": "3550308",
        "gia": "1004",
        "ddd": "11",
        "siafi": "7107"
      })

      Bypass.expect(bypass, "GET", "#{postal_code}/json/", fn conn ->
        conn
        |> Conn.put_resp_header("content-type", "application/json")
        |> Conn.resp(200, body)
      end)

      response = Client.fetch_address(url, postal_code)

      expected_response =
        {:ok,
         %{
           "bairro" => "Sé",
           "cep" => "01001000",
           "complemento" => "lado ímpar",
           "ddd" => "11",
           "gia" => "1004",
           "ibge" => "3550308",
           "localidade" => "São Paulo",
           "logradouro" => "Praça da Sé",
           "siafi" => "7107",
           "uf" => "SP"
         }}

      assert response == expected_response
    end

    test "When the postal code is invalid", %{bypass: bypass} do
      postal_code = "91001000"

      url = endpoint_url(bypass.port)

      body = ~s({
            "erro": true
          })

      Bypass.expect(bypass, "GET", "#{postal_code}/json/", fn conn ->
        conn
        |> Conn.put_resp_header("content-type", "application/json")
        |> Conn.resp(200, body)
      end)

      response = Client.fetch_address(url, postal_code)

      expected_response = {:needs_more_validation, Error.build(:not_found, "CEP not found!")}

      assert response == expected_response
    end

    test "When the postal code is not found", %{bypass: bypass} do
      postal_code = "21001000"

      url = endpoint_url(bypass.port)

      Bypass.expect(bypass, "GET", "#{postal_code}/json/", fn conn ->
        Conn.resp(conn, 400, "")
      end)

      response = Client.fetch_address(url, postal_code)

      expected_response =
        {:needs_more_validation, %Error{result: "Invalid CEP!", status: :bad_request}}

      assert response == expected_response
    end

    test "when there is a generic error", %{bypass: bypass} do
      postal_code = "00000000"

      url = endpoint_url(bypass.port)

      # fechar o servidor somente neste teste
      Bypass.down(bypass)

      response = Client.fetch_address(url, postal_code)

      expected_response = {:error, %Error{result: :econnrefused, status: :bad_request}}

      assert response == expected_response
    end

    defp endpoint_url(port), do: "http://localhost:#{port}/"
  end
end
