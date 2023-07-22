defmodule QuizGameWeb.Router do
  use QuizGameWeb, :router

  import QuizGameWeb.UserAuth

  alias QuizGameWeb.Router.Base, as: BaseRouter

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

  scope "/", QuizGameWeb do
    pipe_through :browser

    use BaseRouter, :base_allow_any_user
  end

  # DEV #
  use BaseRouter, :base_dev

  ## Authentication routes

  scope "/", QuizGameWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/login", UserLoginLive, :new
      live "/users/reset-password", UserForgotPasswordLive, :new
      live "/users/reset-password/:token", UserResetPasswordLive, :edit
    end

    post "/users/login", UserSessionController, :create
  end

  scope "/", QuizGameWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/me", UserSessionController, :show
    get "/users/me/update", UserSessionController, :settings

    live_session :require_authenticated_user,
      on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
      live "/users/me/update/email", UserUpdateEmailLive, :edit
      live "/users/me/update/email/confirm/:token", UserUpdateEmailLive, :confirm_email
      live "/users/me/update/password", UserUpdatePasswordLive, :edit
    end
  end

  scope "/", QuizGameWeb do
    pipe_through [:browser]

    get "/users/logout", UserSessionController, :logout_confirm
    delete "/users/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/email", UserConfirmationInstructionsLive, :new
      live "/users/confirm/email/:token", UserConfirmationLive, :edit
    end
  end
end
