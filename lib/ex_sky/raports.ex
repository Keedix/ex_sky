defmodule ExSky.Raports do
  @moduledoc """
  The Raports context.
  """

  import Ecto.Query, warn: false
  alias ExSky.Repo

  alias ExSky.Raports.Raport
  alias ExSky.XLSX.Parser

  @doc """
  Creates a raport.

  ## Examples

      iex> create_raport(%{field: value})
      {:ok, %Raport{}}

      iex> create_raport(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_raport(raport) do
    %Raport{
      file: %Plug.Upload{path: path, filename: filename},
      sheet_index: sheet_index,
      fabric: fabric,
      country: country,
      store_number: store_number,
      height_netto: height_netto,
      width_netto: width_netto,
      quantity: quantity
    } = raport

    filename = filename |> String.split(".") |> List.first()

    opts = [
      sheet_index: sheet_index,
      columns: %{
        fabric: fabric,
        country: country,
        store_number: store_number,
        height_netto: height_netto,
        width_netto: width_netto,
        quantity: quantity
      }
    ]

    path
    |> Parser.parse(opts)
    |> Elixlsx.write_to_memory("#{filename}_result.xlsx")
  end

  @doc """
  Updates a raport.

  ## Examples

      iex> update_raport(raport, %{field: new_value})
      {:ok, %Raport{}}

      iex> update_raport(raport, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_raport(%Raport{} = raport, attrs) do
    raport
    |> Raport.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a raport.

  ## Examples

      iex> delete_raport(raport)
      {:ok, %Raport{}}

      iex> delete_raport(raport)
      {:error, %Ecto.Changeset{}}

  """
  def delete_raport(%Raport{} = raport) do
    Repo.delete(raport)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking raport changes.

  ## Examples

      iex> change_raport(raport)
      %Ecto.Changeset{data: %Raport{}}

  """
  def change_raport(%Raport{} = raport, attrs \\ %{}) do
    Raport.changeset(raport, attrs)
  end
end
