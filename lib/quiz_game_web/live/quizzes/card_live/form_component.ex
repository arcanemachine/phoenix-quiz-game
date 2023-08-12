defmodule QuizGameWeb.Quizzes.CardLive.FormComponent do
  use QuizGameWeb, :live_component

  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Card

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-4 text-xl font-bold">
        <%= @title %>
      </div>
      <.form_intro_text>
        Use this form to manage card records in your database.
      </.form_intro_text>

      <.simple_form
        for={@form}
        id="card-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:format]}
          type="select"
          label="Format"
          prompt="Choose a value"
          options={Ecto.Enum.values(QuizGame.Quizzes.Card, :format)}
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

  # @impl Phoenix.LiveComponent
  # def update(%{card: card} = assigns, socket) do
  #   changeset = Quizzes.change_card(card)

  #   {:ok,
  #    socket
  #    |> assign(assigns)
  #    |> assign_form(changeset)}
  # end

  @impl Phoenix.LiveComponent
  def update(%{card: card} = assigns, socket) do
    changeset = Card.changeset(card)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"card" => card_params}, socket) do
    changeset =
      socket.assigns.card
      |> Card.changeset(card_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"card" => card_params}, socket) do
    save_card(socket, socket.assigns.action, card_params)
  end

  defp save_card(socket, :new, safe_card_params) do
    # associate card with its quiz
    unsafe_card_params = %{quiz_id: socket.assigns.quiz.id}

    unsafe_changeset =
      Card.unsafe_changeset(%Card{}, Map.merge(safe_card_params, unsafe_card_params))

    case Quizzes.create_card(unsafe_changeset) do
      {:ok, card} ->
        notify_parent({:saved, card})

        {:noreply,
         socket
         |> put_flash(:info, "Card created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = unsafe_error_changeset} ->
        safe_error_changeset = Card.changeset_make_safe(unsafe_error_changeset)
        {:noreply, assign_form(socket, safe_error_changeset)}
    end
  end

  defp save_card(socket, :edit, card_params) do
    changeset = Card.changeset(socket.assigns.card, card_params)

    case Quizzes.update_card(changeset) do
      {:ok, card} ->
        notify_parent({:saved, card})

        {:noreply,
         socket
         |> put_flash(:info, "Card updated successfully")
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
