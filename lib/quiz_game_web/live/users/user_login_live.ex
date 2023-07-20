defmodule QuizGameWeb.UserLoginLive do
  use QuizGameWeb, :live_view

  @page_title "Account Login"

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form, page_title: @page_title), temporary_assigns: [form: form]}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto">
      <p class="text-center">To login to your account, enter your account details below.</p>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <div class="-my-4 flex flex-center">
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
        </div>

        <:actions>
          <.form_button_cancel />
          <.form_button_submit />
        </:actions>
      </.simple_form>
    </div>

    <.action_links items={[
      %{content: "Register new account", navigate: ~p"/users/register"},
      %{content: "Forgot your password?", href: ~p"/users/reset_password"}
    ]} />
    """
  end
end
