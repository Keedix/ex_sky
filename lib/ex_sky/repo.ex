defmodule ExSky.Repo do
  use Ecto.Repo,
    otp_app: :ex_sky,
    adapter: Ecto.Adapters.Postgres
end
