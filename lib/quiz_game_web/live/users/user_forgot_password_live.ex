defmodule QuizGameWeb.UsersLive.UserForgotPasswordLive do
  use QuizGameWeb, :live_view
  alias QuizGame.Users

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Reset Your Password", form: to_form(%{}, as: "user"))}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.form_intro_text>
      Fill out the form, and we will send you an email with a link to reset your password.
    </.form_intro_text>

    <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
      <.input field={@form[:email]} type="email" label="Your email" required />
      <.input type="captcha" />

      <:actions>
        <.simple_form_actions_default />
      </:actions>
    </.simple_form>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send_email", %{"user" => %{"email" => email}} = form_params, socket) do
    if QuizGameWeb.Support.form_captcha_valid?(form_params) do
      if user = Users.get_user_by_email(email) do
        Users.deliver_user_reset_password_instructions(
          user,
          &url(~p"/users/reset-password/#{&1}")
        )
      end

      info =
        "If your email is in our system, then check your email inbox for password reset instructions."

      {:noreply,
       socket
       |> put_flash(:info, info)
       |> redirect(to: ~p"/")}
    else
      {:noreply,
       socket
       |> push_event("toast-show-error", %{
         content: "You must complete the human test at the bottom of the form."
       })
       |> push_event("captcha-reset", %{})}
    end
  end
end
