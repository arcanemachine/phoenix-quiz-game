defmodule QuizGameWeb.Quizzes.QuizTakeLive do
  use QuizGameWeb, :live_view

  import Ecto.Query
  import QuizGameWeb.Support, only: [get_record_or_404: 1]

  alias QuizGame.Quizzes.Quiz

  def get_quiz_or_404(params) do
    query = from q in Quiz, where: q.id == ^params["quiz_id"], preload: [:cards]
    get_record_or_404(query)
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    quiz = get_quiz_or_404(params)

    {:ok,
     socket
     |> assign(%{
       quiz: quiz,
       card: quiz.cards |> Enum.at(0),
       form: to_form(%{}, as: "quiz_take"),
       current_card_index: 0,
       score: 0,
       quiz_is_completed: false
     })}
  end

  @doc """
  Safely converts `user_answer` param to one of the 4 Card choice atoms.

  If a bad value is detected, the answer is converted to 1.
  """
  @spec convert_user_answer_to_choice_atom(String.t()) ::
          :choice_1 | :choice_2 | :choice_3 | :choice_4
  def convert_user_answer_to_choice_atom(user_answer) do
    # convert choice to integer
    choice_int =
      try do
        String.to_integer(user_answer)
      rescue
        _ -> 1
      end

    # ensure value is in the range of 1-4
    choice_int = if choice_int in 1..4, do: choice_int, else: 1

    String.to_atom("choice_#{choice_int}")
  end

  @impl Phoenix.LiveView
  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(%{
       quiz: socket.assigns.quiz,
       card: socket.assigns.quiz.cards |> Enum.at(0),
       form: to_form(%{}, as: "quiz_take"),
       current_card_index: 0,
       score: 0,
       quiz_is_completed: false
     })}
  end

  def handle_event("submit", params, socket) do
    ## Check the validity of the card and proceed to the next card (or finish the quiz).
    card = socket.assigns.card

    # check if user answer is correct
    {user_answer, correct_answer} =
      case socket.assigns.card.format do
        :multiple_choice ->
          # convert choice indices to actual answers
          user_choice = convert_user_answer_to_choice_atom(params["user-answer"])
          user_answer = Map.get(card, user_choice)
          correct_answer = Map.get(card, String.to_atom("choice_#{card.correct_answer}"))

          # get correct answer
          {user_answer, correct_answer}

        _ ->
          {params["user-answer"], card.correct_answer}
      end

    # check if answer was correct and dispatch the appropriate actions
    socket =
      if user_answer == correct_answer do
        socket
        # show success message
        |> push_event("toast-show-success", %{content: "Correct!"})
        # increment score
        |> assign(:score, socket.assigns.score + 1)
      else
        socket
        # show failure message
        |> push_event("toast-show-error", %{
          content: "Incorrect! The correct answer is '#{correct_answer}'."
        })
      end

    socket =
      if socket.assigns.current_card_index == length(socket.assigns.quiz.cards) - 1 do
        # quiz is completed. display the user's score and offer to restart the quiz.
        assign(socket, %{quiz_is_completed: true})
      else
        # quiz is still in progress. get next card and increment current card index
        next_card = socket.assigns.quiz.cards |> Enum.at(socket.assigns.current_card_index + 1)

        assign(socket, %{
          card: next_card,
          current_card_index: socket.assigns.current_card_index + 1
        })
      end

    {:noreply, socket}
  end
end
