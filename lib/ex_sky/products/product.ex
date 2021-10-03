defmodule ExSky.Products.Product do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias ExSky.Products.PcsToCountry

  @primary_key false
  embedded_schema do
    field(:campaign, :string)
    field(:supplier, :string, default: "Vignold")
    embeds_many(:pcs_to_countries, PcsToCountry, on_replace: :delete)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:supplier, :campaign])
    |> validate_required([:supplier, :campaign])
    |> cast_embed(:pcs_to_countries, required: true)
  end
end
