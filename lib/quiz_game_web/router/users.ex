defmodule QuizGameWeb.Router.Users do
  @moduledoc """
  The Users router.
  """

  # BROWSER #
  def users_allow_any_user do
    quote do
      get "/users/logout", UserSessionController, :logout_confirm
      delete "/users/logout", UserSessionController, :delete
    end
  end

  def users_allow_any_user_live_session do
    quote do
      live "/users/confirm/email", UserConfirmationInstructionsLive, :new
      live "/users/confirm/email/:token", UserConfirmationLive, :edit
    end
  end

  def users_logout_required do
    quote do
      post "/users/login", UserSessionController, :create
    end
  end

  def users_logout_required_live_session do
    quote do
      live "/users/register", UserRegistrationLive, :new
      live "/users/login", UserLoginLive, :new
      live "/users/reset-password", UserForgotPasswordLive, :new
      live "/users/reset-password/:token", UserResetPasswordLive, :edit
    end
  end

  def users_login_required do
    quote do
      get "/users/me", UserSessionController, :show
      get "/users/me/update", UserSessionController, :settings
      # get("/users/me/delete", UsersController, :delete_confirm)
      # delete("/users/me/delete", UsersController, :delete)
    end
  end

  def users_login_required_live_session do
    quote do
      live "/users/me/update/email", UserUpdateEmailLive, :edit
      live "/users/me/update/email/confirm/:token", UserUpdateEmailLive, :confirm_email
      live "/users/me/update/password", UserUpdatePasswordLive, :edit
    end
  end

  @doc """
  When used, dispatch the appropriate function by calling the desired function name as an atom.

  ## Examples

      use UsersRouter, :accounts_allow_any_user
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
