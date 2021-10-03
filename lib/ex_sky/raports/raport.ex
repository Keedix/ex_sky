defmodule ExSky.Raports.Raport do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :sheet_index, :integer, default: 0
    field :file, :map
    field :fabric, :string, default: "Material"
    field :country, :string, default: "Land"
    field :store_number, :string, default: "Hs.-Nr."
    field :width_netto, :string, default: "Breite netto"
    field :height_netto, :string, default: "Höhe netto"
    field :quantity, :string, default: "Menge"
  end

  @doc false
  def changeset(raport, attrs) do
    raport
    |> cast(attrs, [
      :sheet_index,
      :file,
      :fabric,
      :country,
      :store_number,
      :height_netto,
      :width_netto,
      :quantity
    ])
    |> validate_required([:sheet_index, :file])
  end
end
