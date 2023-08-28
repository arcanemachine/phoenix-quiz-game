defmodule QuizGameWeb.Quizzes.CardLive.FormComponent do
  use QuizGameWeb, :live_component

  alias QuizGame.Quizzes

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl Phoenix.LiveComponent
  def update(%{card: card} = assigns, socket) do
    changeset = Quizzes.change_card(card)

    card_format =
      if assigns.action == :new,
        do: nil,
        else: Atom.to_string(changeset.data.format)

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(assigns)
     |> assign(card_format: card_format)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("change", %{"card" => card_params}, socket) do
    # update `card_format` so we can conditionally render format-specific fields (i.e. choices)
    socket = socket |> assign(%{card_format: card_params["format"]})

    # validate the changeset
    changeset =
      socket.assigns.card
      |> Quizzes.change_card(card_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("submit", %{"card" => card_params}, socket) do
    _card_save(socket, socket.assigns.action, card_params)
  end

  defp _card_save(socket, :new, card_params) do
    # associate new card with its quiz
    unsafe_card_params = Map.merge(card_params, %{"quiz_id" => socket.assigns.quiz.id})

    case Quizzes.create_card(unsafe_card_params, unsafe: true) do
      {:ok, card} ->
        notify_parent({:saved, card})

        {:noreply,
         socket
         |> put_flash(:success, "Card created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = error_changeset} ->
        {:noreply, assign_form(socket, error_changeset)}
    end
  end

  defp _card_save(socket, :edit, card_params) do
    case Quizzes.update_card(socket.assigns.card, card_params) do
      {:ok, card} ->
        notify_parent({:saved, card})

        {:noreply,
         socket
         |> put_flash(:success, "Card updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
