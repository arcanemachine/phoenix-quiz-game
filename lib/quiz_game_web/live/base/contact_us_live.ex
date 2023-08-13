defmodule QuizGameWeb.BaseLive.ContactUsLive do
  use QuizGameWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "contact_us"), page_title: "Contact Us")}
  end

  def render(assigns) do
    ~H"""
    <.crud_intro_text>
      <p>Please enter your contact information and message.</p>
      <p>If necessary, we will get back to you as soon as possible.</p>
    </.crud_intro_text>

    <.simple_form for={@form} id="form_contact_us" phx-submit="submit">
      <.input field={@form[:name]} type="text" label="Your name" required />
      <.input field={@form[:email]} type="email" label="Your email" required />
      <.input field={@form[:message]} type="textarea" label="Message" required autocomplete="off" />

      <.input type="captcha" />

      <:actions>
        <.simple_form_actions_default />
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("submit", %{"contact_us" => contact_us_form_params} = form_params, socket) do
    if QuizGameWeb.Support.form_captcha_valid?(form_params) do
      QuizGame.Base.BaseNotifier.deliver_contact_us_form(
        contact_us_form_params["name"],
        contact_us_form_params["email"],
        contact_us_form_params["message"]
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
