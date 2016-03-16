defmodule Ekg.Router do
  use Ekg.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", Ekg do
    pipe_through :api
    resources "/packets", PacketController, except: [:new, :edit]
  end
end
