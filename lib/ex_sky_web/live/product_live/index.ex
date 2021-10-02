defmodule ExSkyWeb.ProductLive.Index do
  use ExSkyWeb, :live_view

  alias ExSky.Countries
  alias ExSky.Products
  alias ExSky.Products.{Product, PcsToCountry}

  @impl true
  def mount(_params, _session, socket) do
    changeset = Products.change_product(%Product{})
    countries = Countries.list_countries() |> Enum.map(&elem(&1, 1))

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:countries, countries)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  def handle_event("save", %{"product" => product}, socket) do
    changeset =
      %Product{}
      |> Product.changeset(product)
      |> Map.put(:action, :save)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("validate", %{"product" => product}, socket) do
    changeset =
      %Product{}
      |> Product.changeset(product)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("add-country", _params, socket) do
    country_changeset =
      Products.change_pcs_to_country(%PcsToCountry{temp_id: Ecto.UUID.generate()})

    pcs_to_countries =
      case Ecto.Changeset.get_change(socket.assigns.changeset, :pcs_to_countries) do
        nil ->
          [country_changeset]

        existing_changes ->
          List.insert_at(existing_changes, -1, country_changeset)
      end

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_embed(:pcs_to_countries, pcs_to_countries)

    {:noreply, assign(socket, :changeset, changeset)}
  end
end
