defmodule QuizGameWeb.UserResetPasswordLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users

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

  def render(assigns) do
    ~H"""
    <.form_text_intro>
      Fill out the form to finish resetting your password.
    </.form_text_intro>

    <.simple_form
      for={@form}
      id="reset_password_form"
      phx-submit="reset_password"
      phx-change="validate"
    >
      <.input field={@form[:password]} type="password" label="New password" required />
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

  # to avoid a leaked token giving the user access to the account, do not log the user in after
  # resetting their password
  def handle_event("reset_password", %{"user" => user_params}, socket) do
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
    if user = Users.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
