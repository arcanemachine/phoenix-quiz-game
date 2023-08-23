defmodule QuizGameWeb.Quizzes.QuizTakeLive do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Quizzes.Quiz
  alias QuizGameWeb.Support

  defp _get_quiz_or_404(params) do
    query = from q in Quiz, where: q.id == ^params["quiz_id"], preload: [:cards]
    Support.Repo.record_get_or_404(query)
  end

  defp _initialize_socket(socket) do
    user = socket.assigns.current_user

    socket
    |> assign(
      quiz: socket.assigns.quiz,
      quiz_state: (user && :before_start) || :enter_display_name,
      display_name: (user && user.display_name) || nil,
      card: socket.assigns.quiz.cards |> Enum.at(0),
      current_card_index: 0,
      score: 0
    )
  end

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    quiz = _get_quiz_or_404(params)

    {:ok,
     socket
     |> assign(
       current_path: route(:quizzes, :take, Support.Map.params_to_keyword_list(params)),
       quiz: quiz
     )
     |> _initialize_socket()}
  end

  defp _get_progress_percentage_as_integer(assigns) do
    (assigns.current_card_index / length(assigns.quiz.cards) * 100) |> round() |> trunc()
  end

  defp _get_score_percentage_as_integer(assigns) do
    (assigns.score / (assigns.current_card_index + 1) * 100) |> round() |> trunc()
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

    String.to_existing_atom("choice_#{choice_int}")
  end

  @impl Phoenix.LiveView
  def handle_event("submit-display-name", %{"display-name" => display_name}, socket) do
    if String.trim(display_name) != "" do
      {:noreply, socket |> assign(display_name: display_name, quiz_state: :before_start)}
    else
      {:noreply, socket |> put_flash(:error, "You must enter a display name.")}
    end
  end

  def handle_event("start-quiz", _params, socket) do
    {:noreply,
     socket
     |> clear_flash()
     |> put_flash(:info, "The quiz is now in progress. Good luck!")
     |> assign(quiz_state: :in_progress)}
  end

  # def handle_event("change-display-name", _params, socket) do
  #   socket = socket |> clear_flash()

  #   if socket.assigns.current_user do
  #     {:noreply,
  #      socket
  #      |> put_flash(:warning, "To change your display name, you must update your user profile.")}
  #   else
  #     {:noreply, socket |> assign(:display_name, nil)}
  #   end
  # end

  def handle_event("submit-user-answer", params, %{assigns: assigns} = socket) do
    ## Check the validity of the card and proceed to the next card (or finish the quiz).
    card = assigns.card

    # check if user answer is correct
    {user_answer, correct_answer} =
      case card.format do
        :multiple_choice ->
          # convert choice indices to actual answers
          user_choice = convert_user_answer_to_choice_atom(params["user-answer"])
          user_answer = Map.get(card, user_choice)
          correct_answer = Map.get(card, String.to_atom("choice_#{card.correct_answer}"))

          # get correct answer
          {user_answer, correct_answer}

        _ ->
          {String.downcase(params["user-answer"]), card.correct_answer}
      end

    # check if answer was correct and dispatch the appropriate actions
    socket =
      if user_answer == correct_answer do
        socket
        # show success message
        |> clear_flash()
        |> put_flash(:success, "Correct!")
        # increment score
        |> assign(score: assigns.score + 1)
      else
        socket
        # show failure message
        |> clear_flash()
        |> put_flash(:error, "Incorrect! The correct answer is '#{correct_answer}'.")
      end

    # check if quiz is completed
    if assigns.current_card_index == length(assigns.quiz.cards) - 1 do
      # quiz is completed. update quiz_state
      {:noreply, socket |> assign(quiz_state: :completed)}
    else
      # quiz is still in progress. get next card and increment current card index
      next_card = assigns.quiz.cards |> Enum.at(assigns.current_card_index + 1)

      {:noreply,
       socket
       |> assign(
         card: next_card,
         current_card_index: assigns.current_card_index + 1
       )}
    end
  end

  def handle_event("reset-quiz", _params, socket) do
    {:noreply, _initialize_socket(socket)}
  end
end
