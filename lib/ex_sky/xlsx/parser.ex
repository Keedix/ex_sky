defmodule ExSky.XLSX.Parser do
  @moduledoc """
  Documentation for `ViInvoice`.
  """

  alias Elixlsx.{Workbook, Sheet}
  require Logger

  @first_headers ["Kraj", "Materiał", "Powierzchnia materiału (m^2)", "Liczba woreczków"]
  @second_headers ["Kraj", "Liczba sklepów", "Liczba paczek"]
  @fabric "Material"
  @country "Land"
  @store_number "Hs.-Nr."
  @width_netto "Breite netto"
  @height_netto "Höhe netto"
  @quantity "Menge"
  @order_number "Auftrags Nr."

  @doc """
  Przetwarza plik `.xlsl` zbierając statystyki.

  ## Argumenty
   - `input_file_path` - pełna ścieżka do pliku wejściowego
   - `output_file_path` - pełna ścieżka do pliku wyjściowego
   - `opts` - list opcja
    - `opts.sheet_index` - numer sheet rozpoczynajac od 0
    - `opts.columns` - mapa kluczy do nadpisania nazw kolumn pliku wejściowego
      - `opts.columns.fabric`
      - `opts.columns.country`
      - `opts.columns.store_number`
      - `opts.columns.width_netto`
      - `opts.columns.height_netto`
      - `opts.columns.quantity`


  ## Examples

      iex> ViInvoice.parse("/Users/aukle/projects/vi_invoice/zlecenie.xlsx", "/Users/aukle/projects/vi_invoice/resultat.xlsx", [
        sheet_index: 0,
        columns: %{
          fabric: "Material",
          country: "Land",
          store_number: "Hs.-Nr.",
          width_netto: "Breite netto",
          height_netto: "Höhe netto",
          quantity: "Menge"
        }
      ])
      {:ok, '/Users/aukle/projects/vi_invoice/resultat.xlsx'}

  """
  @spec parse(String.t(), Keyword.t()) :: Workbook.t()
  def parse(input_path, opts \\ []) do
    sheet_index = Keyword.get(opts, :sheet_index, 0)

    columns = Keyword.get(opts, :columns, %{})

    fabric = Map.get(columns, :fabric, @fabric)
    country = Map.get(columns, :country, @country)
    store_number = Map.get(columns, :store_number, @store_number)
    order_number = Map.get(columns, :order_number, @order_number)
    width_netto = Map.get(columns, :width_netto, @width_netto)
    height_netto = Map.get(columns, :height_netto, @height_netto)
    quantity = Map.get(columns, :quantity, @quantity)

    [column_names | rest] =
      input_path
      |> Path.expand(__DIR__)
      |> Xlsxir.stream_list(sheet_index)
      |> Enum.to_list()
      |> Enum.filter(fn row ->
        case Enum.all?(row, &is_nil(&1)) do
          true -> false
          false -> true
        end
      end)

    country_index = Enum.find_index(column_names, &(&1 == country))

    raport =
      rest
      |> aggregate_by(country_index)
      |> Enum.reduce([], fn {country, stores}, acc ->
        acc ++
          sum_products(stores, column_names, country, [
            fabric,
            width_netto,
            height_netto,
            quantity
          ])
      end)

    country_shops_number =
      rest
      |> aggregate_by(country_index)
      |> calculate_shops_number_per_country(column_names, store_number, order_number)

    rows = [@first_headers] ++ raport ++ [[], []] ++ [@second_headers] ++ country_shops_number

    %Workbook{sheets: [%Sheet{name: "Invoice", rows: rows}]}
  end

  defp sum_products(stores, column_names, country, [fabric, width_netto, height_netto, quantity]) do
    fabric_index = Enum.find_index(column_names, &(&1 == fabric))

    stores
    |> aggregate_by(fabric_index)
    |> Enum.map(fn {fabric_type, fabric_stores} ->
      {product_area, bags_number} =
        Enum.reduce(fabric_stores, {_area = 0, _bags = 0}, fn fabric_store, {area, bags} ->
          width_netto_index = Enum.find_index(column_names, &(&1 == width_netto))
          height_netto_index = Enum.find_index(column_names, &(&1 == height_netto))
          quantity_index = Enum.find_index(column_names, &(&1 == quantity))

          width_metre = Enum.fetch!(fabric_store, width_netto_index) / 1000
          height_metre = Enum.fetch!(fabric_store, height_netto_index) / 1000
          quantity = Enum.fetch!(fabric_store, quantity_index)

          {area + width_metre * height_metre * quantity, bags + quantity}
        end)

      [country, fabric_type, product_area, bags_number]
    end)
  end

  defp aggregate_by(list, index) do
    Enum.reduce(list, %{}, fn ele, acc ->
      key = Enum.fetch!(ele, index)

      case Map.get(acc, key) do
        nil ->
          Map.put(acc, key, [ele])

        values ->
          Map.put(acc, key, [ele | values])
      end
    end)
  end

  defp calculate_shops_number_per_country(list, column_names, store_number, order_number) do
    store_number_index = Enum.find_index(column_names, &(&1 == store_number))
    order_number_index = Enum.find_index(column_names, &(&1 == order_number))

    Enum.reduce(list, [], fn {country, shops}, acc ->
      count_shops =
        shops
        |> Enum.uniq_by(fn shop ->
          Enum.fetch!(shop, store_number_index)
        end)
        |> Enum.count()

      count_packages =
        shops
        |> Enum.uniq_by(fn shop ->
          {Enum.fetch!(shop, store_number_index), Enum.fetch!(shop, order_number_index)}
        end)
        |> Enum.count()

      [[country, count_shops, count_packages] | acc]
    end)
  end
end
