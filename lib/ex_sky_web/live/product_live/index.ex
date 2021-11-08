defmodule ExSkyWeb.ProductLive.Index do
  use ExSkyWeb, :live_view

  alias ExSky.Countries
  alias ExSky.Products
  alias ExSky.Products.{Product, PcsToCountry}

  @impl true
  def mount(_params, _session, socket) do
    countries = Countries.list_countries()

    pcs_to_countries =
      Enum.reduce(countries, [], fn {id, name}, acc ->
        List.insert_at(
          acc,
          -1,
          Products.change_pcs_to_country(%PcsToCountry{temp_id: id, country: name})
        )
      end)

    changeset = Products.change_product(%Product{pcs_to_countries: pcs_to_countries})

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:countries, countries)
      |> reset_checked_data()

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

  def handle_event(
        "validate",
        %{"_target" => ["product", "pcs_to_countries", _index, _]} = params,
        socket
      ) do
    pcs =
      params
      |> get_in(["product", "pcs_to_countries"])
      |> Enum.reduce([], fn {_index, changes}, acc ->
        pcs_to_country =
          %Products.PcsToCountry{}
          |> Products.PcsToCountry.changeset(changes)
          |> Ecto.Changeset.apply_changes()

        List.insert_at(acc, -1, pcs_to_country)
      end)
      |> Enum.sort_by(&String.downcase(&1.country))

    changeset = Ecto.Changeset.put_embed(socket.assigns.changeset, :pcs_to_countries, pcs)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["product", "campaign"]} = params,
        socket
      ) do
    changeset =
      Products.Product.changeset(socket.assigns.changeset, %{
        "campaign" => get_in(params, ["product", "campaign"])
      })

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "validate",
        %{"_target" => ["product", "suplier"]} = params,
        socket
      ) do
    changeset =
      Products.Product.changeset(socket.assigns.changeset, %{
        "suplier" => get_in(params, ["product", "suplier"])
      })

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

  defp reset_checked_data(socket) do
    {_, checkboxes} =
      Enum.reduce(socket.assigns.countries, {0, %{}}, fn _, {index, acc} ->
        {index + 1, Map.put(acc, index, false)}
      end)

    assign(socket, :checkboxes, checkboxes)
  end
end
