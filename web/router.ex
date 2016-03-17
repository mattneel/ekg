defmodule Ekg.Router do
  use Ekg.Web, :router


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end
  
  pipeline :api do
    plug :accepts, ["json"]
  end
  
  scope "/", Ekg do
    pipe_through :browser
    get "/", PageController, :index
  end
  
  scope "/api/v1", Ekg do
    pipe_through :api
    resources "/packets", PacketController, except: [:new, :edit]
    resources "/command", CommandController, except: [:new, :edit, :index, :show, :update, :delete]
  end
end
