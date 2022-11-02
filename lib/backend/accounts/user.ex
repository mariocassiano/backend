defmodule Backend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Accounts.Address

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @fields_that_can_be_inserted ~w(name cpf)a
  @fields_that_can_be_updated ~w(name)a
  @required_fields ~w(name cpf)a

  @derive {Jason.Encoder, only: ~w(id name cpf address)a}

  schema "users" do
    field :name, :string
    field :cpf, :string

    embeds_one :address, Address, on_replace: :delete

    timestamps()
  end

  def build(changeset), do: apply_action(changeset, :insert)

  def changeset(struct \\ %__MODULE__{}, %{} = params, fields \\ @required_fields) do
    struct
    |> cast(params, @fields_that_can_be_inserted)
    |> validate_required(fields)
    |> validate_length(:name, max: 255)
    |> validate_length(:cpf, is: 11)
    |> validate_format(:cpf, ~r/([0-9]{11})/)
    |> cast_embed(:address)
    |> unique_constraint(:cpf)
  end

  def changeset_to_update(struct, %{} = params) do
    struct
    |> cast(params, @fields_that_can_be_updated)
    |> validate_required(@required_fields)
    |> cast_embed(:address)
  end
end
