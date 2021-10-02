defmodule ExSky.Countries.Country do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:name, :string)
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
