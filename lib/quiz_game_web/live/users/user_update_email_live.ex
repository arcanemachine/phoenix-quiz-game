defmodule QuizGameWeb.UsersLive.UserUpdateEmailLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @impl Phoenix.LiveView
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Users.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :success, "Email updated successfully")

        :error ->
          put_flash(
            socket,
            :error,
            "Email update link is invalid, expired, or has already been used."
          )
      end

    {:ok, push_navigate(socket, to: ~p"/users/me")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Users.change_user_email(user)

    socket =
      assign(socket, %{
        page_title: "Update Email",
        current_email: user.email,
        email_form_current_email: nil,
        current_password: nil,
        email_form_current_password: nil,
        email_form: to_form(email_changeset),
        trigger_submit: false
      })

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.form_intro_text>
      <p>Complete this form, and we will send a confirmation email to your new email address.</p>
      <p>To confirm your new email address, open that email and click on the activation link.</p>
    </.form_intro_text>

    <.simple_form for={@email_form} id="email_form" phx-submit="email_update" phx-change="validate">
      <.input
        field={@email_form[:email]}
        type="email"
        label="New email"
        value={@email_form_current_email}
        maxlength={User.email_length_max()}
        required
      />
      <.input
        field={@email_form[:current_password]}
        name="current_password"
        id="current_password_for_email"
        type="password"
        label="Confirm your password"
        value={@email_form_current_password}
        maxlength={User.password_length_max()}
        required
      />
      <:actions>
        <.form_button_cancel url={route(:users, :settings)} />
        <.form_button_submit />
      </:actions>
    </.simple_form>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", params, socket) do
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

  def handle_event("email_update", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Users.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Users.deliver_email_update_instructions(
          applied_user,
          user.email,
          &unverified_url(QuizGameWeb.Endpoint, route(:users, :email_update_confirm, token: &1))
        )

        {:noreply,
         socket
         |> put_flash(:info, "Almost done! Check your email inbox for a confirmation link.")
         |> assign(email_form_current_email: nil, email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
