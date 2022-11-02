defmodule Backend.Accounts.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @fields_that_can_be_changed ~w(postal_code street number complement neighborhood city state)a
  @required_fields ~w(postal_code)a
  @optional_fields ~w(street neighborhood city state)a

  @derive {Jason.Encoder, only: ~w(postal_code street number complement neighborhood city state)a}

  embedded_schema do
    field :postal_code, :string
    field :street, :string
    field :complement, :string
    field :number, :integer
    field :neighborhood, :string
    field :city, :string
    field :state, :string
  end

  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, @fields_that_can_be_changed)
    |> validate_length(:postal_code, is: 8)
    |> validate_format(:postal_code, ~r/([0-9]{8})/)
    |> validate_required(@required_fields)
  end

  def build(
        %{
          "cep" => postal_code,
          "logradouro" => street,
          "complemento" => complement,
          "number" => number,
          "bairro" => neighborhood,
          "localidade" => city,
          "uf" => state
        },
        needs_more_validation \\ nil
      ) do
    %__MODULE__{}
    |> cast(
      %{
        postal_code: postal_code,
        street: street,
        complement: complement,
        number: number,
        neighborhood: neighborhood,
        city: city,
        state: state
      },
      @fields_that_can_be_changed
    )
    |> validate_required(@required_fields)
    |> validate_optional(needs_more_validation)
    |> apply_action(:update)
  end

  def update(params, data) do
    Map.replace!(params, "address", %{
      "postal_code" => data.postal_code,
      "complement" => data.complement,
      "number" => data.number,
      "neighborhood" => data.neighborhood,
      "city" => data.city,
      "state" => data.state,
      "street" => data.street
    })
  end

  defp validate_optional(struct, needs_more_validation) do
    case needs_more_validation do
      :needs_more_validation ->
        struct
        |> validate_required(@optional_fields)

      _ ->
        struct
    end
  end
end
