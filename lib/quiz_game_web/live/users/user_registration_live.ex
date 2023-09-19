defmodule QuizGameWeb.UsersLive.UserRegistrationLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @impl true
  def mount(_params, _session, socket) do
    changeset = Users.change_user_registration(%User{})

    socket =
      socket
      |> assign(
        page_title: "Register New Account",
        trigger_submit: false,
        check_errors: false
      )
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

  @impl true
  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      To register a new account, enter your account details below.
    </.crud_intro_text>

    <.simple_form
      id="user-registration-form"
      for={@form}
      has_errors={@check_errors}
      action={route(:users, :login) <> query_string(action: "registered")}
      method="post"
      phx-change="validate"
      phx-submit="save"
      phx-trigger-action={@trigger_submit}
    >
      <.input
        field={@form[:username]}
        type="text"
        label="Username"
        help_text="A unique username used to identify you"
        minlength={User.username_length_min()}
        maxlength={User.username_length_max()}
        required
      />
      <.input
        field={@form[:display_name]}
        type="text"
        label="Display name"
        help_text="The name that will be shown when you take a quiz"
        maxlength={User.display_name_length_max()}
        required
      />
      <.input
        field={@form[:email]}
        type="email"
        label="Email"
        help_text="Your email address"
        maxlength={User.email_length_max()}
        required
      />
      <.input
        field={@form[:password]}
        type="password"
        label="Password"
        help_text="Enter a secure password"
        minlength={User.password_length_min()}
        maxlength={User.password_length_max()}
        required
      />
      <.input
        field={@form[:password_confirmation]}
        type="password"
        label="Confirm password"
        help_text="Re-enter your password to make sure it was entered correctly"
        minlength={User.password_length_min()}
        maxlength={User.password_length_max()}
        required
      />

      <.input type="captcha" />

      <:actions>
        <.form_actions_default />
      </:actions>
    </.simple_form>

    <.action_links>
      <.action_links_item>
        <.link href={route(:users, :login)}>
          Login to an existing account
        </.link>
      </.action_links_item>
      <.spacer />
      <.action_links_item>
        <.link href={route(:users, :reset_password_solicit)}>
          Forgot your password?
        </.link>
      </.action_links_item>
      <.action_links_item>
        <.link href={route(:users, :verify_email_solicit)}>
          Didn't receive a confirmation email?
        </.link>
      </.action_links_item>
    </.action_links>
    """
  end

  @impl true
  def handle_event("save", %{"user" => user_params} = form_params, socket) do
    # check if the captcha is valid
    if S.HTML.Form.captcha_valid?(form_params) do
      # captcha valid. attempt to register the user
      case Users.register_user(user_params) do
        # registration successful
        {:ok, user} ->
          # deliver a confirmation email to the user
          {:ok, _} =
            Users.deliver_email_verify_instructions(
              user,
              &unverified_url(
                QuizGameWeb.Endpoint,
                route(:users, :verify_email_confirm, token: &1)
              )
            )

          # create an empty changeset so we can clear the form before navigating away from it
          changeset = Users.change_user_registration(user)

          # clear all form fields and redirect to the login view
          {:noreply,
           socket
           |> push_event("captcha-reset", %{})
           |> assign_form(changeset)
           |> redirect(to: route(:users, :register_success))}

        # registration failed
        {:error, %Ecto.Changeset{} = changeset} ->
          # reset the captcha field and show errors to the user
          {:noreply,
           socket
           |> assign(check_errors: true)
           |> push_event("captcha-reset", %{})
           |> assign_form(changeset)}
      end
    else
      # captcha invalid. show an error toast message and clear the captcha field
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
