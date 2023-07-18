defmodule QuizGameWeb.Router do
  use QuizGameWeb, :router

  alias QuizGameWeb.Router.Base, as: BaseRouter

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuizGameWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QuizGameWeb do
    pipe_through :browser

    use BaseRouter, :base_allow_any_user
  end

  # DEV #
  use BaseRouter, :base_dev
end
