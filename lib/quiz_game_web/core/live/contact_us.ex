defmodule QuizGameWeb.Core.Live.ContactUs do
  @moduledoc false
  use QuizGameWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}), page_title: "Contact Us")}
  end

  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      <p>Please enter your contact information and message.</p>
      <p>If necessary, we will get back to you as soon as possible.</p>
    </.crud_intro_text>

    <.simple_form id="contact-us-form" for={@form} phx-submit="submit">
      <.input field={@form[:name]} type="text" label="Your name" required />
      <.input field={@form[:email]} type="email" label="Your email" required />
      <.input field={@form[:message]} type="textarea" label="Message" required autocomplete="off" />

      <.input type="captcha" />

      <:actions>
        <.form_actions_default />
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("submit", form_params, socket) do
    if QuizGameWeb.Support.HTML.Form.captcha_valid?(form_params) do
      QuizGame.Core.CoreNotifier.deliver_contact_us_form(
        form_params["name"],
        form_params["email"],
        form_params["message"]
      )

      success_message = "Contact form submitted successfully. Thank you for your feedback!"

      {:noreply,
       socket
       |> put_flash(:success, success_message)
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
