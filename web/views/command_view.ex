defmodule Ekg.CommandView do
  use Ekg.Web, :view

  def render("show.json", %{status: "OK"}) do
    %{data: "OK"}
  end

end
