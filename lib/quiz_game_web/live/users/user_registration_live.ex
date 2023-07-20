defmodule QuizGameWeb.UserRegistrationLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @page_title "Register New Account"

  def mount(_params, _session, socket) do
    changeset = Users.change_user_registration(%User{})

    socket =
      socket
      |> assign(page_title: @page_title)
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Users.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Users.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Users.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def render(assigns) do
    ~H"""
    <section class="mx-auto">
      <p class="text-center">To register a new account, enter your account details below.</p>

      <.simple_form
        for={@form}
        has_errors={@check_errors}
        id="registration_form"
        action={~p"/users/login?_action=registered"}
        method="post"
        phx-change="validate"
        phx-submit="save"
        phx-trigger-action={@trigger_submit}
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.form_button_cancel />
          <.form_button_submit />
        </:actions>
      </.simple_form>

      <.action_links items={[
        %{content: "Login to an existing account", navigate: ~p"/users/login"}
      ]} />
    </section>
    """
  end
end
