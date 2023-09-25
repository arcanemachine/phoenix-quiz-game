defmodule QuizGameWeb.Users.User.Live.UpdateDisplayName do
  @moduledoc false

  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @impl true
  def mount(params, _session, socket) do
    user = socket.assigns.current_user
    changeset = Users.change_user_display_name(user, %{display_name: user.display_name})

    socket =
      socket
      |> assign(
        page_title: "Update Display Name",
        form: to_form(changeset),
        success_url: Map.get(params, "next") || ~p"/users/me/update"
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      Fill out the form below to change your display name.
    </.crud_intro_text>

    <.simple_form
      id="user-update-display-name-form"
      for={@form}
      autocomplete="off"
      phx-change="validate"
      phx-submit="submit"
    >
      <.input
        field={@form[:display_name]}
        type="text"
        label="Your new display name"
        maxlength={User.display_name_length_max()}
        required
      />
      <:actions>
        <.form_button_cancel />
        <.form_button_submit />
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def handle_event("submit", %{"user" => %{"display_name" => display_name}}, socket) do
    user = socket.assigns.current_user

    case Users.update_user_display_name(user, display_name) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:success, "Display name updated successfully")
         |> redirect(to: socket.assigns.success_url)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"user" => %{"display_name" => display_name}}, socket) do
    form =
      socket.assigns.current_user
      |> Users.change_user_display_name(%{display_name: display_name})
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end
end
