defmodule Ekg.Router do
  use Ekg.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", Ekg do
    pipe_through :api
    resources "/packets", PacketController, except: [:new, :edit]
    resources "/command", CommandController, except: [:new, :edit, :index, :show, :update, :delete]
  end
end
