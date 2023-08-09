defmodule QuizGameWeb.UsersLive.UserRegistrationLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @page_title "Register New Account"

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.form_intro_text>
      To register a new account, enter your account details below.
    </.form_intro_text>

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
      <.input field={@form[:username]} type="text" label="Username" required />
      <.input
        field={@form[:email]}
        type="email"
        label="Email"
        maxlength={User.email_length_max()}
        required
      />
      <.input
        field={@form[:password]}
        type="password"
        label="Password"
        minlength={User.password_length_min()}
        maxlength={User.password_length_max()}
        required
      />
      <.input
        field={@form[:password_confirmation]}
        type="password"
        label="Confirm password"
        minlength={User.password_length_min()}
        maxlength={User.password_length_max()}
        required
      />

      <.input type="captcha" />

      <:actions>
        <.simple_form_actions_default />
      </:actions>
    </.simple_form>

    <.action_links>
      <.action_links_item>
        <.link href={~p"/users/login"}>
          Login to an existing account
        </.link>
      </.action_links_item>
      <.action_links_spacer />
      <.action_links_item>
        <.link href={~p"/users/reset-password"}>
          Forgot your password?
        </.link>
      </.action_links_item>
      <.action_links_item>
        <.link href={~p"/users/confirm/email"}>
          Didn't receive a confirmation email?
        </.link>
      </.action_links_item>
    </.action_links>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"user" => user_params} = form_params, socket) do
    if QuizGameWeb.Support.form_captcha_valid?(form_params) do
      case Users.register_user(user_params) do
        {:ok, user} ->
          {:ok, _} =
            Users.deliver_user_confirmation_instructions(
              user,
              &url(~p"/users/confirm/email/#{&1}")
            )

          changeset = Users.change_user_registration(user)

          {:noreply,
           socket
           |> push_event("captcha-reset", %{})
           |> assign(trigger_submit: true)
           |> assign_form(changeset)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply,
           socket
           |> assign(check_errors: true)
           |> push_event("captcha-reset", %{})
           |> assign_form(changeset)}
      end
    else
      changeset = Users.change_user_registration(%User{}, user_params)

      {:noreply,
       socket
       |> push_event("toast-show-error", %{
         content: "You must complete the human test at the bottom of the form."
       })
       |> push_event("captcha-reset", %{})
       |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Users.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end
end
