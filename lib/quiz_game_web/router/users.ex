defmodule QuizGameWeb.Router.Users do
  @moduledoc """
  The Users router.
  """

  def browser do
    quote do
      # allow any user
      scope "/users", QuizGameWeb do
        pipe_through(:browser)

        get "/logout", UserSessionController, :logout_confirm
        post "/logout", UserSessionController, :logout

        live_session :confirm_email,
          on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
          live "/confirm/email", UserConfirmationInstructionsLive, :new
          live "/confirm/email/:token", UserConfirmationLive, :edit
        end
      end

      # logout required
      scope "/users", QuizGameWeb do
        pipe_through([:browser, :redirect_if_user_is_authenticated])

        post "/login", UserSessionController, :create

        live_session :redirect_if_user_is_authenticated,
          on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
          live "/register", UserRegistrationLive, :new
          live "/login", UserLoginLive, :new
          live "/reset-password", UserForgotPasswordLive, :new
          live "/reset-password/:token", UserResetPasswordLive, :edit
        end
      end

      # login required
      scope "/users", QuizGameWeb do
        pipe_through([:browser, :require_authenticated_user])

        get "/me", UserSessionController, :show
        get "/me/update", UserSessionController, :settings
        get "/me/delete", UserController, :delete_confirm
        post "/me/delete", UserController, :delete

        live_session :require_authenticated_user,
          on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
          live "/me/update/email", UserUpdateEmailLive, :edit
          live "/me/update/email/confirm/:token", UserUpdateEmailLive, :confirm_email
          live "/me/update/password", UserUpdatePasswordLive, :edit
        end
      end
    end
  end

  @doc """
  When used, dispatch the appropriate function by calling the desired function name as an atom.

  ## Examples

      use UsersRouter, :users_browser
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
