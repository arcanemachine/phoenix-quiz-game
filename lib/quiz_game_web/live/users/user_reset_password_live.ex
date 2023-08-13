defmodule QuizGameWeb.UsersLive.UserResetPasswordLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params) |> assign(page_title: "Set New Password")

    form_source =
      case socket.assigns do
        %{user: user} ->
          Users.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      Fill out the form to finish resetting your password.
    </.crud_intro_text>

    <.simple_form
      for={@form}
      id="password_reset_form"
      phx-submit="password_reset"
      phx-change="validate"
    >
      <.input
        field={@form[:password]}
        type="password"
        label="New password"
        minlength={User.password_length_min()}
        maxlength={User.password_length_max()}
        required
      />
      <.input
        field={@form[:password_confirmation]}
        type="password"
        label="Confirm new password"
        required
      />
      <:actions>
        <.simple_form_actions_default />
      </:actions>
    </.simple_form>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("password_reset", %{"user" => user_params}, socket) do
    # to avoid a leaked token giving the user access to the account, do not log the user in after
    # resetting their password
    case Users.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Password reset successfully.")
         |> redirect(to: ~p"/users/login")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Users.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Users.get_user_by_password_reset_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid, expired, or has already been used.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
