defmodule QuizGameWeb.UsersLive.UserUpdatePasswordLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    password_changeset = Users.change_user_password(user)

    socket =
      socket
      |> assign(:page_title, "Update Password")
      |> assign(:email, user.email)
      |> assign(:current_password, nil)
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      Fill out the form below to change your password.
    </.crud_intro_text>

    <.simple_form
      for={@password_form}
      id="password_form"
      action={route(:users, :login) <> query_string(_action: "password_updated")}
      method="post"
      phx-change="validate"
      phx-submit="password_update"
      phx-trigger-action={@trigger_submit}
    >
      <%!-- email field is required to update the password --%>
      <.input field={@password_form[:email]} type="hidden" value={@email} />
      <.input
        field={@password_form[:current_password]}
        name="current_password"
        type="password"
        label="Current password"
        id="current_password_for_password"
        value={@current_password}
        maxlength={User.password_length_max()}
        required
      />
      <.input
        field={@password_form[:password]}
        type="password"
        label="New password"
        minlength={User.password_length_min()}
        maxlength={User.password_length_max()}
        required
      />
      <.input
        field={@password_form[:password_confirmation]}
        type="password"
        minlength={User.password_length_min()}
        maxlength={User.password_length_max()}
        label="Confirm new password"
      />
      <:actions>
        <.form_button_cancel url={route(:users, :settings)} />
        <.form_button_submit />
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def handle_event("validate", %{"current_password" => password, "user" => user_params}, socket) do
    password_form =
      socket.assigns.current_user
      |> Users.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("password_update", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Users.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Users.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
