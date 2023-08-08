defmodule QuizGameWeb.Router do
  use QuizGameWeb, :router

  use Kaffy.Routes,
    scope: "/admin",
    pipe_through: [:fetch_current_user, :require_admin_user]

  import QuizGameWeb.Support.Plug
  import QuizGameWeb.UserAuth

  # # API
  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  # BROWSER
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

  # BASE - allow any user
  scope "/", QuizGameWeb do
    pipe_through :browser

    get "/", BaseController, :root
    live "/contact-us", BaseLive.ContactUsLive, :contact_us
    get "/privacy-policy", BaseController, :privacy_policy
    get "/terms-of-use", BaseController, :terms_of_use
  end

  # QUIZZES - login required
  scope "/quizzes", QuizGameWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/", QuizController, param: "quiz_id", except: [:index, :show]
  end

  # QUIZZES - allow any user
  scope "/quizzes", QuizGameWeb do
    pipe_through [:browser]

    resources "/", QuizController, param: "quiz_id", only: [:index, :show]
  end

  # USERS - login required
  scope "/users", QuizGameWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/me", UserController, :show
    get "/me/update", UserController, :settings
    get "/me/delete", UserController, :delete_confirm
    post "/me/delete", UserController, :delete

    live_session :login_required,
      on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
      live "/me/update/email", UsersLive.UserUpdateEmailLive, :edit
      live "/me/update/email/confirm/:token", UsersLive.UserUpdateEmailLive, :confirm_email
      live "/me/update/password", UsersLive.UserUpdatePasswordLive, :edit
    end
  end

  # USERS - logout required
  scope "/users", QuizGameWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    post "/login", UserSessionController, :create

    live_session :logout_required,
      on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UsersLive.UserRegistrationLive, :new
      live "/login", UsersLive.UserLoginLive, :new
      live "/reset-password", UsersLive.UserForgotPasswordLive, :new
      live "/reset-password/:token", UsersLive.UserResetPasswordLive, :edit
    end
  end

  # USERS - allow any user
  scope "/users", QuizGameWeb do
    pipe_through :browser

    get "/logout", UserSessionController, :logout_confirm
    post "/logout", UserSessionController, :logout

    live_session :allow_any_user,
      on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
      live "/confirm/email", UsersLive.UserConfirmationInstructionsLive, :new
      live "/confirm/email/:token", UsersLive.UserConfirmationLive, :edit
    end
  end

  # DEV
  if Application.compile_env(:quiz_game, :dev_routes) do
    import Phoenix.LiveDashboard.Router
    alias QuizGameWeb.DevLive

    scope "/dev" do
      pipe_through :browser

      # built-in routes
      live_dashboard("/dashboard", metrics: QuizGameWeb.Telemetry)
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      # custom project routes
      live("/component-showcase", DevLive.ComponentShowcaseLive)
    end
  end
end
