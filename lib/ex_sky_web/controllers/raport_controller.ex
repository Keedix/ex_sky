defmodule ExSkyWeb.RaportController do
  use ExSkyWeb, :controller

  alias ExSky.Raports
  alias ExSky.Raports.Raport

  def new(conn, _params) do
    changeset = Raports.change_raport(%Raport{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"raport" => raport_params}) do
    params_changeset = Raports.change_raport(%Raport{}, raport_params)

    with true <- params_changeset.valid?,
         raport <- Ecto.Changeset.apply_changes(params_changeset),
         {:ok, {file_name, output}} <- Raports.create_raport(raport) do
      conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", "attachment; filename=#{file_name}")
      |> send_resp(201, output)
    else
      _ ->
        {:error, params_changeset}
    end
  end
end
