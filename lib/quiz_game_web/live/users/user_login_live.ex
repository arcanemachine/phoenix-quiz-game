defmodule QuizGameWeb.UsersLive.UserLoginLive do
  use QuizGameWeb, :live_view
  alias QuizGame.Users.User

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, page_title: "Account Login"),
     temporary_assigns: [form: form]}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.form_intro_text>
      To login to your account, enter your account details below.
    </.form_intro_text>

    <.simple_form for={@form} id="login_form" action={route(:users, :login)} phx-update="ignore">
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
        maxlength={User.password_length_max()}
        required
      />

      <div class="-my-4 flex flex-center">
        <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
      </div>

      <.input type="captcha" />

      <:actions>
        <.simple_form_actions_default />
      </:actions>
    </.simple_form>

    <.action_links>
      <.action_links_item>
        <.link href={route(:users, :register)}>
          Register new account
        </.link>
      </.action_links_item>
      <.action_links_spacer />
      <.action_links_item>
        <.link href={route(:users, :password_reset)}>
          Forgot your password?
        </.link>
      </.action_links_item>
      <.action_links_item>
        <.link href={route(:users, :email_verify_solicit)}>
          Didn't receive a confirmation email?
        </.link>
      </.action_links_item>
    </.action_links>
    """
  end
end
