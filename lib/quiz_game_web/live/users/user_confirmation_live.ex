defmodule QuizGameWeb.UsersLive.UserConfirmationLive do
  use QuizGameWeb, :live_view
  alias QuizGame.Users

  @impl Phoenix.LiveView
  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")

    {:ok, assign(socket, form: form, page_title: "Confirm Your Email"),
     temporary_assigns: [form: nil]}
  end

  @impl Phoenix.LiveView
  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.crud_intro_text>
        Click the button below to confirm your account.
      </.crud_intro_text>

      <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
        <.input field={@form[:token]} type="hidden" />
        <:actions>
          <.form_button_submit content="Confirm my account" class="btn-lg w-full" />
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    # to avoid a leaked token giving the user access to the account, do not log the user in after
    # confirming their email
    case Users.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Your email address has been confirmed.")
         |> redirect(to: ~p"/users/me")}

      :error ->
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply,
             socket
             |> put_flash(:info, "Your email address has already been confirmed.")
             |> redirect(to: ~p"/users/me")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(
               :error,
               "Email confirmation link is invalid, expired, or has already been used."
             )
             |> redirect(to: ~p"/")}
        end
    end
  end
end
