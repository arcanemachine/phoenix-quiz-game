defmodule QuizGameWeb.Router.Users do
  @moduledoc """
  The Users router.
  """

  def users_browser do
    quote do
      # allow any user
      scope "/", QuizGameWeb do
        pipe_through(:browser)

        get "/users/logout", UserSessionController, :logout_confirm
        post "/users/logout", UserSessionController, :logout

        live_session :current_user,
          on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
          live "/users/confirm/email", UserConfirmationInstructionsLive, :new
          live "/users/confirm/email/:token", UserConfirmationLive, :edit
        end
      end

      # logout required
      scope "/", QuizGameWeb do
        pipe_through([:browser, :redirect_if_user_is_authenticated])

        post "/users/login", UserSessionController, :create

        live_session :redirect_if_user_is_authenticated,
          on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
          live "/users/register", UserRegistrationLive, :new
          live "/users/login", UserLoginLive, :new
          live "/users/reset-password", UserForgotPasswordLive, :new
          live "/users/reset-password/:token", UserResetPasswordLive, :edit
        end
      end

      # login required
      scope "/", QuizGameWeb do
        pipe_through([:browser, :require_authenticated_user])

        get "/users/me", UserSessionController, :show
        get "/users/me/update", UserSessionController, :settings
        get "/users/me/delete", UserController, :delete_confirm
        post "/users/me/delete", UserController, :delete

        live_session :require_authenticated_user,
          on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
          live "/users/me/update/email", UserUpdateEmailLive, :edit
          live "/users/me/update/email/confirm/:token", UserUpdateEmailLive, :confirm_email
          live "/users/me/update/password", UserUpdatePasswordLive, :edit
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
