defmodule QuizGameWeb.Quizzes.QuizTakeLive do
  use QuizGameWeb, :live_view

  import Ecto.Query

  alias QuizGameWeb.Presence
  alias QuizGame.Quizzes.{Card, Quiz}
  alias QuizGameWeb.Support

  @presence_topic "quiz_presence"

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    # get quiz or 404
    query = from q in Quiz, where: q.id == ^params["quiz_id"], preload: [:cards]
    quiz = Support.Repo.get_record_or_404(query)

    # redirect if quiz does not have any cards or random math questions
    if Enum.empty?(quiz.cards) && !quiz.math_random_question_count do
      {:ok,
       socket
       |> put_flash(:error, "This quiz cannot be taken because it has no cards.")
       |> redirect(to: route(:quizzes, :show, quiz_id: quiz.id))}
    else
      _maybe_track_user(socket, quiz)

      {:ok,
       socket
       |> assign(
         current_path: route(:quizzes, :take, Support.Map.params_to_keyword_list(params)),
         quiz: quiz
       )
       |> _initialize_socket()}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("submit-display-name", %{"display-name" => display_name}, socket) do
    if String.trim(display_name) != "" do
      {:noreply,
       socket
       |> assign(display_name: display_name, quiz_state: :before_start)}

      # |> _maybe_track_user(socket.assigns.quiz)}
    else
      {:noreply, socket |> put_flash(:error, "You must enter a display name.")}
    end
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

  def handle_event("start-quiz", _params, socket) do
    {:noreply,
     socket
     |> clear_flash()
     |> put_flash(:info, "The quiz is now in progress. Good luck!")
     |> assign(quiz_state: :in_progress)}
  end

  def handle_event("submit-user-answer", params, %{assigns: assigns} = socket) do
    user_answer = _get_user_answer(assigns.card, params)
    correct_answer = _get_correct_answer(assigns.card)

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
    quiz_is_completed = assigns.current_card_index == _get_quiz_length(assigns.quiz) - 1

    if quiz_is_completed do
      # create quiz record
      QuizGame.Quizzes.create_record(%{
        quiz_id: assigns.quiz.id,
        user_id: (assigns.current_user && assigns.current_user.id) || nil,
        display_name: assigns.display_name,
        card_count: length(assigns.quiz.cards),
        score: assigns.score
      })

      {:noreply, socket |> assign(quiz_state: :completed)}
    else
      # get next card and increment current card index
      {:noreply, socket |> _assign_next_card_and_index()}
    end
  end

  # def handle_event("reset-quiz", _params, socket) do
  #   {:noreply, _initialize_socket(socket)}
  # end

  # answer
  @spec _get_correct_answer(Card) :: [integer() | String.t()]
  defp _get_correct_answer(card) do
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

  @spec _get_user_answer(Card, map()) :: [integer() | String.t()]
  defp _get_user_answer(card, params) do
    get_choice_atom_from_user_answer = fn user_answer ->
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

    case card.format do
      :multiple_choice ->
        # convert choice index to actual answer
        user_choice = get_choice_atom_from_user_answer.(params["user-answer"])
        user_answer = Map.get(card, user_choice)

        user_answer

      :random_math_question ->
        String.to_integer(params["user-answer"])

      :number_entry ->
        params["user-answer"]

      _ ->
        String.downcase(params["user-answer"])
    end
  end

  # assigns
  defp _assign_next_card_and_index(socket) do
    quiz = socket.assigns.quiz
    next_card_index = socket.assigns.current_card_index + 1

    card =
      if quiz.math_random_question_count do
        min = quiz.math_random_question_value_min
        max = quiz.math_random_question_value_max

        # build random math question
        first_value = Enum.random(min..max)
        second_value = Enum.random(min..max)
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

        # return card-like map containing random math question data
        %{
          format: :random_math_question,
          question: question_as_string,
          first_value: first_value,
          second_value: second_value,
          operation: operation
        }
      else
        # get next card for the quiz
        quiz.cards |> Enum.at(next_card_index)
      end

    socket |> assign(card: card, current_card_index: next_card_index)
  end

  # presence
  defp _maybe_track_user(socket, quiz) do
    if connected?(socket) && socket.assigns.current_user do
      Presence.track_user(self(), @presence_topic, quiz.id, socket.assigns.current_user)
    end
  end

  # quiz
  defp _get_quiz_length(quiz) do
    # add the number of cards to the number of random math questions
    length(quiz.cards) + (quiz.math_random_question_count || 0)
  end

  # socket
  defp _initialize_socket(socket) do
    user = socket.assigns.current_user

    socket
    |> assign(
      quiz: socket.assigns.quiz,
      quiz_state: (user && :before_start) || :enter_display_name,
      display_name: (user && user.display_name) || nil,
      current_card_index: 0,
      card: socket.assigns.quiz.cards |> Enum.at(0),
      score: 0
    )
  end

  # support
  defp _get_progress_percentage_as_integer(assigns) do
    (assigns.current_card_index / _get_quiz_length(assigns.quiz) * 100) |> round() |> trunc()
  end

  defp _get_score_percentage_as_integer(assigns) do
    (assigns.score / (assigns.current_card_index + 1) * 100) |> round() |> trunc()
  end
end
