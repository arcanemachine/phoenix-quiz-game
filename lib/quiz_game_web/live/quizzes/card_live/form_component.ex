defmodule QuizGameWeb.Quizzes.CardLive.FormComponent do
  use QuizGameWeb, :live_component

  alias QuizGame.Quizzes

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-4 text-xl font-bold">
        <%= @title %>
      </div>
      <.crud_intro_text>
        Use this form to manage card records in your database.
      </.crud_intro_text>

      <.simple_form for={@form} id="card-form" phx-target={@myself} phx-submit="save">
        <.input
          field={@form[:format]}
          type="select"
          label="Format"
          prompt="Choose a value"
          options={QuizGame.Quizzes.Card.format_options()}
        />
        <.input field={@form[:question]} type="text" label="Question" />
        <.input field={@form[:image]} type="text" label="Image" />
        <.input
          field={@form[:answers]}
          type="select"
          multiple
          label="Answers"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Card</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(%{card: card} = assigns, socket) do
    changeset = Quizzes.change_card(card)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"card" => card_params}, socket) do
    changeset =
      socket.assigns.card
      |> Quizzes.change_card(card_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"card" => card_params}, socket) do
    save_card(socket, socket.assigns.action, card_params)
  end

  defp save_card(socket, :new, safe_card_params) do
    # associate new card with its quiz
    unsafe_card_params = Map.merge(safe_card_params, %{"quiz_id" => socket.assigns.quiz.id})

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

  defp save_card(socket, :edit, card_params) do
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
