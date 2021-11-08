defmodule ExSkyWeb.RaportView do
  use ExSkyWeb, :view

  def format_input_name(name) do
    name
    |> Atom.to_string()
    |> String.capitalize()
    |> String.replace("_", " ")
  end
end
