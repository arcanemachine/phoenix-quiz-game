defmodule QuizGameWeb.Router do
  use QuizGameWeb, :router

  import QuizGameWeb.UserAuth

  alias QuizGameWeb.Router.Base, as: BaseRouter
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
  # allow any user
  scope "/", QuizGameWeb do
    pipe_through(:browser)

    use BaseRouter, :base_allow_any_user
    use UsersRouter, :users_allow_any_user

    live_session :current_user,
      on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
      use UsersRouter, :users_live_session_allow_any_user
    end
  end

  # logout required
  scope "/", QuizGameWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    use UsersRouter, :users_logout_required

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      use UsersRouter, :users_live_session_logout_required
    end
  end

  # login required
  scope "/", QuizGameWeb do
    pipe_through([:browser, :require_authenticated_user])

    use UsersRouter, :users_login_required

    live_session :require_authenticated_user,
      on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
      use UsersRouter, :users_live_session_login_required
    end
  end

  # DEV #
  use BaseRouter, :base_dev
end
