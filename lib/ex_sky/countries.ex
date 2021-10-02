defmodule ExSky.Countries do
  @moduledoc """
  The Countries context.
  """

  alias ExSky.Countries.Country

  @doc """
  Returns the list of countries.

  ## Examples

      iex> list_countries()
      [%Country{}, ...]

  """
  def list_countries do
    :countries
    |> :dets.select([{{:"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.sort_by(fn {_, name} -> name end)
  end

  @doc """
  Creates a country.

  ## Examples

      iex> create_country(%{field: value})
      {:ok, %Country{}}

      iex> create_country(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country(attrs \\ %{}) do
    changeset = Country.changeset(%Country{}, attrs)

    with %Ecto.Changeset{valid?: true} = changeset <- changeset,
         country <- Ecto.Changeset.apply_changes(changeset),
         :ok <- :dets.insert(:countries, {Ecto.UUID.generate(), country.name}) do
      {:ok, country}
    else
      _ ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a country.

  ## Examples

      iex> delete_country(country)
      {:ok, %Country{}}

      iex> delete_country(country)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country(id) do
    :dets.delete(:countries, id)
  end

  def get_country!(id) do
    :dets.lookup(:countries, id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.

  ## Examples

      iex> change_country(country)
      %Ecto.Changeset{data: %Country{}}

  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, attrs)
  end
end
