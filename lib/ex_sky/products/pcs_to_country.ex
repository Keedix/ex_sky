defmodule ExSky.Products.PcsToCountry do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:country, :string)
    field(:number_of_products, :integer)
    field(:temp_id, :string, virtual: true)
  end

  @doc false
  def changeset(pcs_to_countries, attrs) do
    pcs_to_countries
    |> cast(attrs, [:country, :number_of_products])
    |> validate_required([:country, :number_of_products])
  end
end
