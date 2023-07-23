defmodule QuizGameWeb.Router do
  use QuizGameWeb, :router

  import QuizGameWeb.UserAuth

  alias QuizGameWeb.Router.Base, as: BaseRouter
  alias QuizGameWeb.Router.Dev, as: DevRouter
  alias QuizGameWeb.Router.Users, as: UsersRouter

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuizGameWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # BROWSER #
  use BaseRouter, :base_browser
  use UsersRouter, :users_browser

  # DEV #
  use DevRouter
end
