defmodule ExSky.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias ExSky.Countries

  @countries [
    "AT (Österreich)",
    "BE (Belgien)",
    "CH (Schweiz)",
    "CZ (Tschechien)",
    "ES (Spanien)",
    "FR (Frankreich)",
    "HR (Kroatien)",
    "HU (Ungarn)",
    "IT (Italien)",
    "LU (Luxemburg)",
    "Melilla",
    "NL (Niederlande)",
    "PL (Polen)",
    "RO (Romänien)",
    "RS (Serbien)",
    "SK (Slowakei)",
    "SL (Slowenien)"
  ]

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # ExSky.Repo,
      # Start the Telemetry supervisor
      ExSkyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExSky.PubSub},
      # Start the Endpoint (http/https)
      ExSkyWeb.Endpoint,
      # Start a worker by calling: ExSky.Worker.start_link(arg)
      # {ExSky.Worker, arg}
      {ChromicPDF, chromic_pdf_opts()},
      {Task,
       fn ->
         if [] == Countries.list_countries() do
           @countries
           |> Enum.map(&%{name: &1})
           |> Enum.each(&Countries.create_country/1)
         end
       end}
    ]

    {:ok, _} = :dets.open_file(:countries, [])
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExSky.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExSkyWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp chromic_pdf_opts do
    [chrome_executable: "google-chrome-stable"]
  end
end
