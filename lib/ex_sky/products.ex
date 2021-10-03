defmodule ExSky.Products do
  @moduledoc """
  The Products context.
  """

  alias ExSky.Products.{Product, PcsToCountry}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pcs_to_country changes.

  ## Examples

      iex> change_pcs_to_country(pcs_to_country)
      %Ecto.Changeset{data: %PcsToCountry{}}

  """
  def change_pcs_to_country(%PcsToCountry{} = pcs_to_country, attrs \\ %{}) do
    PcsToCountry.changeset(pcs_to_country, attrs)
  end

  @doc """
  Prints Product to pdf using HTML template.
  """

  @spec print_to_pdf(map(), fun()) :: {:ok, any()} | {:error, Ecto.Changeset.t()}
  def print_to_pdf(product, callback) do
    changeset = Product.changeset(%Product{}, product)

    with {:ok, products} <- validate_changeset(changeset) do
      assigns =
        Enum.reduce(products.pcs_to_countries, [], fn
          %{number_of_products: 0}, acc ->
            acc

          pcs_to_country, acc ->
            assigns =
              Enum.map(0..(pcs_to_country.number_of_copies - 1), fn _index ->
                %{
                  supplier: products.supplier,
                  campaign: products.campaign,
                  country: pcs_to_country.country,
                  number_of_products: pcs_to_country.number_of_products
                }
              end)

            acc
            |> List.insert_at(-1, assigns)
            |> List.flatten()
        end)

      template =
        "download.html"
        |> ExSkyWeb.ProductView.render(products: assigns)
        |> Phoenix.HTML.safe_to_string()

      ChromicPDF.print_to_pdf({:html, template},
        print_to_pdf: %{
          marginTop: 0,
          marginLeft: 0,
          marginRight: 0,
          marginBottom: 0,
          displayHeaderFooter: false,
          preferCSSPageSize: true
        },
        output: &callback.(&1)
      )
    end
  end

  defp validate_changeset(%Ecto.Changeset{valid?: true} = changeset) do
    {:ok, Ecto.Changeset.apply_changes(changeset)}
  end

  defp validate_changeset(changeset), do: {:error, changeset}
end
