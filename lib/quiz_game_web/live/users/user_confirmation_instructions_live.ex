defmodule QuizGameWeb.UsersLive.UserConfirmationInstructionsLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users
  alias QuizGame.Users.User

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"), page_title: "Resend Confirmation Email")}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      Fill out the form, and we will send you an email with a link to confirm your account.
    </.crud_intro_text>

    <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input
        field={@form[:email]}
        type="email"
        label="Your email"
        maxlength={User.email_length_max()}
        required
      />
      <.input type="captcha" />

      <:actions>
        <.form_actions_default />
      </:actions>
    </.simple_form>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("send_instructions", %{"user" => %{"email" => email}} = form_params, socket) do
    if QuizGameWeb.Support.HTML.form_captcha_valid?(form_params) do
      if user = Users.get_user_by_email(email) do
        Users.deliver_email_verify_instructions(
          user,
          &unverified_url(QuizGameWeb.Endpoint, route(:users, :email_verify_confirm, token: &1))
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
