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

  # BASE - allow any user
  scope "/", QuizGameWeb do
    pipe_through :browser

    get "/", BaseController, :root
    live "/contact-us", BaseLive.ContactUsLive, :contact_us
    get "/privacy-policy", BaseController, :privacy_policy
    get "/terms-of-use", BaseController, :terms_of_use
  end

  # quizzes
  scope "/quizzes", QuizGameWeb.Quizzes do
    pipe_through [:browser]

    get "/", QuizController, :index

    scope "/" do
      pipe_through [:require_authenticated_user]

      get "/new", QuizController, :new
      post "/", QuizController, :create
    end

    scope "/:quiz_id" do
      pipe_through [:fetch_quiz]

      # quizzes
      get "/", QuizController, :show
      live "/take", QuizTakeLive, :take

      scope "/" do
        pipe_through [:require_authenticated_user, :require_quiz_permissions]

        get "/edit", QuizController, :edit
        put "/", QuizController, :update
        patch "/", QuizController, :update
        delete "/", QuizController, :delete
      end

      # cards
      scope "/cards" do
        live "/", CardLive.Index, :index

        live_session :quizzes_cards_login_required,
          on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
          live "/new", CardLive.Index, :new
        end

        scope "/:card_id" do
          live "/", CardLive.Show, :show

          live_session :quizzes_id_cards_login_required,
            on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
            live "/edit", CardLive.Show, :edit
          end
        end
      end
    end
  end

  # USERS - login required
  scope "/users/me", QuizGameWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", UserController, :show
    get "/quizzes", UserController, :quizzes_index

    scope "/edit" do
      get "/", UserController, :settings

      live_session :login_required,
        on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
        live "/email", UsersLive.UserUpdateEmailLive, :edit
        live "/email/confirm/:token", UsersLive.UserUpdateEmailLive, :confirm_email
        live "/password", UsersLive.UserUpdatePasswordLive, :edit
      end
    end

    get "/delete", UserController, :delete_confirm
    post "/delete", UserController, :delete
  end

  # USERS - logout required
  scope "/users", QuizGameWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    post "/login", UserSessionController, :create

    live_session :logout_required,
      on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UsersLive.UserRegistrationLive, :new, as: :users_register
      live "/login", UsersLive.UserLoginLive, :new, as: :users_login
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
      live "/verify/email", UsersLive.UserConfirmationInstructionsLive, :new
      live "/verify/email/:token", UsersLive.UserConfirmationLive, :edit
    end
  end

  # SUPPORT - admin
  use Kaffy.Routes,
    scope: "/support/admin",
    pipe_through: [:fetch_current_user, :require_admin_user]

  # SUPPORT - dev
  if Application.compile_env(:quiz_game, :dev_routes) do
    import Phoenix.LiveDashboard.Router
    alias QuizGameWeb.DevLive

    scope "/support/dev" do
      pipe_through :browser

      # built-in routes
      live_dashboard("/dashboard", metrics: QuizGameWeb.Telemetry)
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      # custom project routes
      live("/component-showcase", DevLive.ComponentShowcaseLive)
    end
  end
end
