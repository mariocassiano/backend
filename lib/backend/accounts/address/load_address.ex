defmodule Backend.Accounts.Address.LoadAddress do
  @moduledoc """
  Fetch address in external api by postal_code.
  """
  alias Backend.Accounts.Address

  @doc """
  Fetch address in external api by postal_code.
  """
  def call(%{"address" => address} = params) do
    response_address = client().fetch_address(address["postal_code"])

    case response_address do
      {:needs_more_validation, _} ->
        params
        |> parse_with_more_validation(address)

      {:ok, body} ->
        body
        |> parse_without_more_validation(address)
    end
  end

  defp client do
    :backend
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.get(:via_cep_adapter)
  end

  defp parse_with_more_validation(params, address) do
    params
    |> Map.put("cep", address["postal_code"])
    |> Map.put("logradouro", address["street"])
    |> Map.put("complemento", address["complement"])
    |> Map.put("number", address["number"])
    |> Map.put("bairro", address["neighborhood"])
    |> Map.put("localidade", address["city"])
    |> Map.put("uf", address["state"])
    |> Address.build(:needs_more_validation)
  end

  defp parse_without_more_validation(params, address) do
    params
    |> Map.replace("cep", address["postal_code"])
    |> Map.replace("complemento", address["complement"])
    |> Map.put("number", address["number"])
    |> Address.build()
  end
end
