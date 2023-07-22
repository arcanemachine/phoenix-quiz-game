defmodule QuizGameWeb.UserConfirmationLive do
  use QuizGameWeb, :live_view

  alias QuizGame.Users

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")

    {:ok, assign(socket, form: form, page_title: "Confirm Your Account"),
     temporary_assigns: [form: nil]}
  end

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.form_text_intro>
        Click the button below to confirm your account.
      </.form_text_intro>

      <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
        <.input field={@form[:token]} type="hidden" />
        <:actions>
          <.form_button kind="success" content="Confirm my account" class="btn-lg w-full" />
        </:actions>
      </.simple_form>
    </div>
    """
  end

  # to avoid a leaked token giving the user access to the account, do not log the user in after
  # confirming their email
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    case Users.confirm_user(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "User confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
