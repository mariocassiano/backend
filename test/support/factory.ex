defmodule Backend.Factory do
  use ExMachina.Ecto, repo: Backend.Repo

  alias Backend.Accounts.{Address, User}

  def user_params_factory do
    %{
      "name" => "Mario Cassiano",
      "cpf" => "12345678901",
      "address" => address_params_factory()
    }
  end

  def address_params_factory do
    %{
      "postal_code" => "01001000",
      "street" => "Praça da Sé",
      "complement" => "lado ímpar",
      "number" => "1846",
      "neighborhood" => "Sé",
      "city" => "São Paulo",
      "state" => "SP"
    }
  end

  def user_factory do
    %User{
      id: "af01c441-d16f-45dc-aa61-2dee8d72824f",
      name: "Mario Cassiano",
      cpf: "12345678901",
      address: address_factory()
    }
  end

  def address_factory do
    %Address{
      postal_code: "01001000",
      street: "Praça da Sé",
      complement: "lado ímpar",
      number: "1846",
      neighborhood: "Sé",
      city: "São Paulo",
      state: "SP"
    }
  end

  def postal_code_info_factory do
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
    }
  end
end
