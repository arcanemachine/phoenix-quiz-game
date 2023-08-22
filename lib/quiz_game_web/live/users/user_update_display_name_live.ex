defmodule QuizGameWeb.UsersLive.UserUpdateDisplayNameLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    changeset = Users.change_user_display_name(user, user.display_name)

    socket =
      socket
      |> assign(page_title: "Change Display Name", form: to_form(changeset))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      Fill out the form below to change your display name.
    </.crud_intro_text>

    <.simple_form for={@form} id="form" phx-change="validate" phx-submit="submit">
      <.input
        field={@form[:display_name]}
        name="display-name"
        type="text"
        label="Your new display name"
        maxlength={User.display_name_length_max()}
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
    form =
      socket.assigns.current_user
      |> Users.change_user_display_name(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"display-name" => display_name}, socket) do
    user = socket.assigns.current_user

    case Users.update_user_display_name(user, display_name) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:success, "Display name updated successfully")
         |> redirect(to: route(:users, :show))}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end