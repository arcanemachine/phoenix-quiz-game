defmodule QuizGameWeb.UsersLive.UserUpdateEmailLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Users.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :success, "Email updated successfully")

        :error ->
          put_flash(socket, :error, "Email update link is invalid or expired")
      end

    {:ok, push_navigate(socket, to: ~p"/users/me")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Users.change_user_email(user)

    socket =
      socket
      |> assign(:page_title, "Update Email")
      |> assign(:current_email, user.email)
      |> assign(:email_form_current_email, nil)
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.form_intro_text>
      <p>Complete this form, and we will send a confirmation email to your new email address.</p>
      <p>To confirm your new email address, open that email and click on the activation link.</p>
    </.form_intro_text>

    <.simple_form
      for={@email_form}
      id="email_form"
      phx-submit="update_email"
      phx-change="validate_email"
    >
      <.input
        field={@email_form[:email]}
        type="email"
        label="New email"
        value={@email_form_current_email}
        required
      />
      <.input
        field={@email_form[:current_password]}
        name="current_password"
        id="current_password_for_email"
        type="password"
        label="Confirm your password"
        value={@email_form_current_password}
        required
      />
      <:actions>
        <.form_button_cancel url={~p"/users/me/update"} />
        <.form_button_submit />
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => %{"email" => email} = user_params} = params

    email_form =
      socket.assigns.current_user
      |> Users.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply,
     assign(socket,
       email_form: email_form,
       email_form_current_email: email,
       email_form_current_password: password
     )}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Users.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Users.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/me/update/email/confirm/#{&1}")
        )

        info = "Almost done! Check your email inbox for a confirmation link."

        {:noreply,
         socket
         |> put_flash(:info, info)
         |> assign(email_form_current_email: nil, email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
