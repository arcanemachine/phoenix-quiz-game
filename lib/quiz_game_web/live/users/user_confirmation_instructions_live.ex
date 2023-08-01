defmodule QuizGameWeb.UserConfirmationInstructionsLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"), page_title: "Resend Confirmation Email")}
  end

  def render(assigns) do
    ~H"""
    <.form_text_intro>
      Fill out the form, and we will send you an email with a link to confirm your account.
    </.form_text_intro>

    <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={@form[:email]} type="email" placeholder="Email" required />
      <.input type="captcha" />

      <:actions>
        <.simple_form_actions_default />
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}} = form_params, socket) do
    if QuizGameWeb.Support.form_captcha_valid?(form_params) do
      if user = Users.get_user_by_email(email) do
        Users.deliver_user_confirmation_instructions(
          user,
          &url(~p"/users/confirm/email/#{&1}")
        )
      end

      info =
        "If your email is in our system, and your email has not yet been confirmed, " <>
          "then check your email inbox for password reset instructions."

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
