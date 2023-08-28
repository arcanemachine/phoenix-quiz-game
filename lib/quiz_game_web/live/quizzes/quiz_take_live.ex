defmodule QuizGameWeb.Quizzes.QuizTakeLive do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGame.Quizzes.{Card, Quiz}
  alias QuizGameWeb.Support

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    quiz = _quiz_get_or_404(params)

    # redirect if quiz does not have any cards or random math questions
    if Enum.empty?(quiz.cards) && !quiz.math_random_question_count do
      {:ok,
       socket
       |> put_flash(:error, "This quiz cannot be taken because it has no questions.")
       |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))}
    else
      {:ok,
       socket
       |> assign(
         current_path: route(:quizzes, :take, Support.Map.params_to_keyword_list(params)),
         quiz: quiz
       )
       |> _socket_initialize()}
    end
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
    user_answer = _answer_user_get(assigns.card, params)
    correct_answer = _answer_correct_get(assigns.card)

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
    if assigns.current_card_index == _quiz_length_get(assigns.quiz) - 1 do
      # quiz is completed. update quiz_state
      {:noreply, socket |> assign(quiz_state: :completed)}
    else
      # quiz is still in progress. get next card and increment current card index
      next_card = _card_next_get(assigns.quiz, assigns.current_card_index)

      {:noreply,
       socket
       |> assign(
         card: next_card,
         current_card_index: assigns.current_card_index + 1
       )}
    end
  end

  def handle_event("reset-quiz", _params, socket) do
    {:noreply, _socket_initialize(socket)}
  end

  @spec _answer_correct_get(Card) :: [integer() | String.t()]
  defp _answer_correct_get(card) do
    case card.format do
      :multiple_choice ->
        # convert choice index to actual answer
        Map.get(card, String.to_existing_atom("choice_#{card.correct_answer}"))

      :random_math_question ->
        case card.operation do
          :add -> card.first_value + card.second_value
          :subtract -> card.first_value - card.second_value
          :multiply -> card.first_value * card.second_value
          :divide -> card.first_value / card.second_value
        end

      _ ->
        card.correct_answer
    end
  end

  @spec _answer_user_convert_to_choice_atom(String.t()) ::
          :choice_1 | :choice_2 | :choice_3 | :choice_4
  defp _answer_user_convert_to_choice_atom(user_answer) do
    ## Safely converts `user_answer` param to one of the 4 Card choice atoms.
    ## If a bad value is detected, the answer is converted to 1.

    # convert choice to integer (fallback to 1 for invalid value)
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

  @spec _answer_user_get(Card, map()) :: [integer() | String.t()]
  defp _answer_user_get(card, params) do
    case card.format do
      :multiple_choice ->
        # convert choice index to actual answer
        user_choice = _answer_user_convert_to_choice_atom(params["user-answer"])
        user_answer = Map.get(card, user_choice)

        user_answer

      :random_math_question ->
        String.to_integer(params["user-answer"])

      :number_entry ->
        String.to_integer(params["user-answer"])

      _ ->
        String.downcase(params["user-answer"])
    end
  end

  defp _card_next_get(quiz, current_card_index) do
    if quiz.math_random_question_count do
      # build random math question
      first_value =
        Enum.random(quiz.math_random_question_value_min..quiz.math_random_question_value_max)

      second_value =
        Enum.random(quiz.math_random_question_value_min..quiz.math_random_question_value_max)

      operation = Enum.random(quiz.math_random_question_operations)

      # get string values so we can display the question to the user
      operation_as_string =
        case operation do
          :add -> "+"
          :subtract -> "-"
          :multiply -> "×"
          :divide -> "÷"
        end

      question_as_string = "#{first_value} #{operation_as_string} #{second_value} = ?"

      # generate card with random math question data
      %{
        format: :random_math_question,
        question: question_as_string,
        first_value: first_value,
        second_value: second_value,
        operation: operation
      }
    else
      # get next card for the quiz
      quiz.cards |> Enum.at(current_card_index + 1)
    end
  end

  defp _progress_percentage_get_as_integer(assigns) do
    (assigns.current_card_index / _quiz_length_get(assigns.quiz) * 100) |> round() |> trunc()
  end

  defp _quiz_get_or_404(params) do
    query = from q in Quiz, where: q.id == ^params["quiz_id"], preload: [:cards]
    Support.Repo.record_get_or_404(query)
  end

  defp _quiz_length_get(quiz) do
    length(quiz.cards) + quiz.math_random_question_count
  end

  defp _score_percentage_get_as_integer(assigns) do
    (assigns.score / (assigns.current_card_index + 1) * 100) |> round() |> trunc()
  end

  defp _socket_initialize(socket) do
    user = socket.assigns.current_user

    socket
    |> assign(
      quiz: socket.assigns.quiz,
      quiz_state: (user && :before_start) || :enter_display_name,
      display_name: (user && user.display_name) || nil,
      # card: socket.assigns.quiz.cards |> Enum.at(0),
      card: _card_next_get(socket.assigns.quiz, 0),
      current_card_index: 0,
      score: 0
    )
  end
end
