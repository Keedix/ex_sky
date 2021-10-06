defmodule ExSky.Products.PcsToCountry do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:checked?, :boolean, default: false)
    field(:country, :string)
    field(:number_of_products, :integer, default: 0)
    field(:number_of_copies, :integer, default: 1)
    field(:temp_id, :string, virtual: true, primary_key: true)
  end

  @doc false
  def changeset(pcs_to_countries, attrs) do
    pcs_to_countries
    |> cast(attrs, [:temp_id, :checked?, :country, :number_of_products, :number_of_copies])
    |> validate_number(:number_of_products, greater_than: 0)
    |> validate_required([:country])
  end
end
