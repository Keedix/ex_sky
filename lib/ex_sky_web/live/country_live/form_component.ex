defmodule ExSkyWeb.CountryLive.FormComponent do
  use ExSkyWeb, :live_component

  alias ExSky.Countries

  @impl true
  def update(%{country: country} = assigns, socket) do
    changeset = Countries.change_country(country)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"country" => country_params}, socket) do
    changeset =
      socket.assigns.country
      |> Countries.change_country(country_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"country" => country_params}, socket) do
    save_country(socket, socket.assigns.action, country_params)
  end

  defp save_country(socket, :new, country_params) do
    case Countries.create_country(country_params) do
      {:ok, _country} ->
        {:noreply,
         socket
         |> put_flash(:info, "Country created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
