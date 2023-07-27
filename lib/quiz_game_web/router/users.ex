defmodule QuizGameWeb.Router.Users do
  @moduledoc """
  The router for the 'users' context.
  """

  def routes do
    %{
      root: "/users",

      # auth
      registration: "/register",
      confirmation_instructions: "/confirm/email",
      confirmation: "/confirm/email/:token",
      login: "/login",
      logout: "/logout",
      forgot_password: "/reset-password",
      reset_password: "/reset-password/:token",

      # crud
      show: "/me",
      settings: "/me/update",
      update_email: "/me/update/email",
      update_email_confirm: "/me/update/email/confirm/:token",
      update_password: "/me/update/password",
      delete_confirm: "/me/delete",
      delete: "/me/delete"
    }
  end

  def browser do
    quote do
      # allow any user
      scope @routes.users.root, QuizGameWeb do
        pipe_through(:browser)

        get @routes.users.logout, UserSessionController, :logout_confirm
        post @routes.users.logout, UserSessionController, :logout

        live_session :confirm_email,
          on_mount: [{QuizGameWeb.UserAuth, :mount_current_user}] do
          live @routes.users.confirmation_instructions, UserConfirmationInstructionsLive, :new
          live @routes.users.confirmation, UserConfirmationLive, :edit
        end
      end

      # logout required
      scope @routes.users.root, QuizGameWeb do
        pipe_through([:browser, :redirect_if_user_is_authenticated])

        post @routes.users.login, UserSessionController, :create

        live_session :redirect_if_user_is_authenticated,
          on_mount: [{QuizGameWeb.UserAuth, :redirect_if_user_is_authenticated}] do
          live @routes.users.registration, UserRegistrationLive, :new
          live @routes.users.login, UserLoginLive, :new
          live @routes.users.forgot_password, UserForgotPasswordLive, :new
          live @routes.users.reset_password, UserResetPasswordLive, :edit
        end
      end

      # login required
      scope @routes.users.root, QuizGameWeb do
        pipe_through([:browser, :require_authenticated_user])

        get @routes.users.show, UserSessionController, :show
        get @routes.users.settings, UserSessionController, :settings

        live_session :require_authenticated_user,
          on_mount: [{QuizGameWeb.UserAuth, :ensure_authenticated}] do
          live @routes.users.update_email, UserUpdateEmailLive, :edit
          live @routes.users.update_email_confirm, UserUpdateEmailLive, :confirm_email
          live @routes.users.update_password, UserUpdatePasswordLive, :edit
        end

        get @routes.users.delete_confirm, UserController, :delete_confirm
        post @routes.users.delete, UserController, :delete
      end
    end
  end

  @doc """
  When used, dispatch the appropriate function by calling the desired function name as an atom.

  ## Examples

      use UsersRouter, :users_browser
      use UsersRouter, :users_api
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
