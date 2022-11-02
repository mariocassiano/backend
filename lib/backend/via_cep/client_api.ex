defmodule Backend.ViaCep.ClientApi do
  alias Backend.Error

  @callback fetch_address(String.t()) ::
              {:ok, map()} | {:needs_more_validation, Error} | {:error, Error}
end
