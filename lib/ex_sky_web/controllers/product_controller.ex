defmodule ExSkyWeb.ProductController do
  use ExSkyWeb, :controller

  alias ExSky.Products

  def download(conn, %{"product" => product}) do
    with {:ok, conn} <- Products.print_to_pdf(product, &do_download(&1, &2, conn)) do
      conn
    end
  end

  defp do_download(path, campaign, conn) do
    pdf = File.read!(path)

    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=Palety-#{campaign}.pdf"
    )
    |> send_resp(201, pdf)
  end
end
