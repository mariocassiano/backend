defmodule Backend.ViaCep.Client do
  use Tesla

  alias Backend.Error
  alias Backend.ViaCep.ClientApi
  alias Tesla.Env

  @behaviour ClientApi

  @base_url "https://viacep.com.br/ws/"
  plug Tesla.Middleware.JSON

  def fetch_address(url \\ @base_url, postal_code) do
    "#{url}#{postal_code}/json/"
    |> get()
    |> response_address()
  end

  defp response_address({:ok, %Env{status: 200, body: %{"erro" => true}}}) do
    {:needs_more_validation, Error.build(:not_found, "CEP not found!")}
  end

  defp response_address({:ok, %Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp response_address({:ok, %Env{status: 400, body: _body}}) do
    {:needs_more_validation, Error.build(:bad_request, "Invalid CEP!")}
  end

  defp response_address({:error, reason}) do
    {:error, Error.build(:bad_request, reason)}
  end
end
