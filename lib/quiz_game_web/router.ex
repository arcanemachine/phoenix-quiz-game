defmodule QuizGameWeb.Router do
  use QuizGameWeb, :router

  import QuizGameWeb.Plug
  import QuizGameWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :remove_trailing_slash
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuizGameWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  use QuizGameWeb.Router.Base, :browser
  use QuizGameWeb.Router.Users, :browser

  use QuizGameWeb.Router.Dev

  pipeline :api do
    plug :accepts, ["json"]
  end
end
