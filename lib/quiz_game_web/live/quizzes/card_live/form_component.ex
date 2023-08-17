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

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(
       # assign card_format
       assigns |> Map.put(:card_format, Atom.to_string(changeset.data.format))
     )}
  end

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

      <.simple_form
        for={@form}
        id="card-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:question]} type="text" label="Question" required />

        <.input
          field={@form[:format]}
          type="select"
          label="Format"
          prompt="Choose a value"
          options={QuizGame.Quizzes.Card.format_options()}
          required
        />

        <div :if={@card_format == "multiple_choice"}>
          <.label>Answer Choices</.label>
          <.input field={@form[:choice_1]} type="text" label="Choice 1" required />
          <.input field={@form[:choice_2]} type="text" label="Choice 2" required />
          <.input field={@form[:choice_3]} type="text" label="Choice 3" required />
          <.input field={@form[:choice_4]} type="text" label="Choice 4" required />

          <.input
            field={@form[:answer]}
            type="select"
            label="Answer"
            options={[{"Choice #1", 0}, {"Choice #2", 1}, {"Choice #3", 2}, {"Choice #4", 3}]}
            required
          />
        </div>

        <div :if={@card_format == "true_or_false"}>
          <.input
            field={@form[:answer]}
            type="select"
            label="Answer"
            options={[{"True", "true"}, {"False", "false"}]}
            required
          />
        </div>

        <div :if={@card_format == "text_entry"}>
          <.input field={@form[:answer]} type="text" label="Answer" required />
        </div>

        <div :if={@card_format == "number_entry"}>
          <.input field={@form[:answer]} type="number" label="Answer" required />
        </div>

        <:actions>
          <.form_actions_default />
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"card" => card_params}, socket) do
    # assign card format
    socket = socket |> assign(:card_format, card_params["format"])

    changeset =
      socket.assigns.card
      |> Quizzes.change_card(card_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"card" => card_params}, socket) do
    save_card(socket, socket.assigns.action, card_params)
  end

  defp save_card(socket, :new, card_params) do
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
end
