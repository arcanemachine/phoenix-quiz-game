defmodule QuizGameWeb.Router do
  use QuizGameWeb, :router

  import QuizGameWeb.Support.Plug
  import QuizGameWeb.UserAuth

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

  # CORE - allow any user
  scope "/", QuizGameWeb.Core do
    pipe_through :browser

    get "/", Controller, :root
    live "/contact-us", Live.ContactUs, :contact_us
    get "/privacy-policy", Controller, :privacy_policy
    get "/terms-of-use", Controller, :terms_of_use
  end

  # QUIZZES
  scope "/quizzes", QuizGameWeb.Quizzes do
    pipe_through [:browser]

    # index views
    get "/", Quiz.Controller, :index
    get "/subjects/:subject", Quiz.Controller, :index_subject

    # randomly-generated quizzes
    get "/random", Quiz.Controller, :new_random

    live_session :quiz_take_random,
      on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
      live "/random/take", Quiz.Live.Take, :take_random
    end

    scope "/" do
      pipe_through [:require_authenticated_user]

      get "/new", Quiz.Controller, :new
      post "/new", Quiz.Controller, :create
    end

    scope "/:quiz_id" do
      pipe_through [:fetch_quiz]

      # quizzes
      get "/", Quiz.Controller, :show

      live_session :quiz_take,
        on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
        live "/take", Quiz.Live.Take, :take
      end

      scope "/" do
        pipe_through [:require_authenticated_user, :require_quiz_permissions]

        get "/update", Quiz.Controller, :edit
        put "/update", Quiz.Controller, :update
        patch "/update", Quiz.Controller, :update
        delete "/", Quiz.Controller, :delete

        live_session :quizzes_login_required_quiz_permission_required,
          on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
          live "/stats", Quiz.Live.Stats, :stats
        end
      end

      # cards
      scope "/cards" do
        pipe_through [:require_authenticated_user, :require_quiz_permissions]

        live "/", Card.Live.Index, :index

        live_session :quizzes_cards_login_required,
          on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
          live "/new", Card.Live.Index, :new

          live "/:card_id", Card.Live.Show, :show
          live "/:card_id/update", Card.Live.Show, :edit
        end
      end

      # records
      scope "/records" do
        pipe_through [:require_authenticated_user, :require_quiz_permissions]

        get "/", Record.Controller, :index
        put "/:record_id", Record.Controller, :show
      end
    end
  end

  # USERS - login required
  scope "/users/me", QuizGameWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", UserController, :show
    get "/quizzes", UserController, :quizzes_index
    get "/quizzes/records", UserController, :records_index

    scope "/update" do
      get "/", UserController, :settings

      live_session :login_required,
        on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
        live "/display-name", UsersLive.UserUpdateDisplayNameLive, :edit
        live "/email", UsersLive.UserUpdateEmailLive, :edit
        live "/email/:token", UsersLive.UserUpdateEmailLive, :confirm_email
        live "/password", UsersLive.UserUpdatePasswordLive, :edit
      end
    end

    get "/delete", UserController, :delete_confirm
    post "/delete", UserController, :delete
  end

  # USERS - logout required
  scope "/users", QuizGameWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/register/success", UserSessionController, :register_success
    post "/login", UserSessionController, :create

    live_session :logout_required,
      on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UsersLive.UserRegistrationLive, :new, as: :register
      live "/login", UsersLive.UserLoginLive, :new, as: :login
      live "/reset/password", UsersLive.UserForgotPasswordLive, :new
      live "/reset/password/:token", UsersLive.UserResetPasswordLive, :edit
    end
  end

  # USERS - allow any user
  scope "/users", QuizGameWeb do
    pipe_through :browser

    get "/logout", UserSessionController, :logout_confirm
    post "/logout", UserSessionController, :logout

    live_session :allow_any_user,
      on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
      live "/verify/email", UsersLive.UserConfirmationInstructionsLive, :new
      live "/verify/email/:token", UsersLive.UserConfirmationLive, :edit
    end
  end

  # SUPPORT - admin
  use Kaffy.Routes,
    scope: "/admin",
    pipe_through: [:fetch_current_user, :require_admin_user]

  # SUPPORT - dev
  if Application.compile_env(:quiz_game, :dev_routes) do
    import Phoenix.LiveDashboard.Router
    alias QuizGameWeb.Dev

    scope "/dev" do
      pipe_through :browser

      # built-in routes
      live_dashboard("/dashboard", metrics: QuizGameWeb.Telemetry)
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      # custom project routes
      live("/component-showcase", Dev.Live.ComponentShowcase)
    end
  end
end
