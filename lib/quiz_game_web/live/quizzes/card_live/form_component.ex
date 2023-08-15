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

        <.label>Choices</.label>
        <%= for i <- 0..3 do %>
          <.input
            type="text"
            name={"card[choice-#{i}]"}
            value={@form[:choices].value |> Enum.at(i)}
            placeholder={"Choice #{i+1}" <> ((i+1) <= 2 && " (Required)" || "")}
            show_errors={
              # show error after last input only
              i == length(@form[:choices].value) - 1
            }
            required={
              # must have 2 or more choices
              i + 1 <= 2
            }
          />
        <% end %>

        <.input
          field={@form[:answer]}
          type="select"
          label="Answer"
          options={[{"Choice #1", 0}, {"Choice #2", 1}, {"Choice #3", 2}, {"Choice #4", 3}]}
        />

        <:actions>
          <.form_actions_default />
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

  defp save_card(socket, :new, card_params) do
    parsed_card_params = card_params |> card_params_parse_choices()

    # associate new card with its quiz
    unsafe_card_params = Map.merge(parsed_card_params, %{"quiz_id" => socket.assigns.quiz.id})

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
    parsed_card_params = card_params |> card_params_parse()

    case Quizzes.update_card(socket.assigns.card, parsed_card_params) do
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

  defp card_params_parse(card_params) do
    card_params |> card_params_parse_choices()
  end

  defp card_params_parse_choices(card_params) do
    choice_fields = ["choice-0", "choice-1", "choice-2", "choice-3"]

    # construct a list containing the parsed choices (return empty string for a given value if
    # the field is empty)
    choices_list = for field <- choice_fields, do: card_params |> Map.get(field, nil)

    # remove unparsed choices from params
    filtered_card_params = card_params |> Map.filter(fn {k, _v} -> !Enum.member?(choice_fields, k) end)

    # insert parsed choices into card_params
    parsed_card_params = filtered_card_params |> Map.put("choices", choices_list)

    parsed_card_params
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
