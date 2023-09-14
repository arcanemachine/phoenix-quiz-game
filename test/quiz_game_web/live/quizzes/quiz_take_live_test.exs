defmodule QuizGameWeb.Quizzes.QuizTakeLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Ecto.Query
  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, QuizzesFixtures, UsersFixtures}

  alias QuizGame.Quizzes.{Quiz, Record}
  alias QuizGame.Repo

  defp _get_quiz_take_url(quiz_id), do: route(:quizzes, :take, quiz_id: quiz_id)

  setup %{conn: conn} do
    user = user_fixture()
    conn = conn |> login_user(user)

    # create quiz and cards
    quiz = quiz_fixture(user_id: user.id)

    card_fixture(%{
      quiz_id: quiz.id,
      format: :multiple_choice,
      question: "What is 2 + 2?",
      choice_1: "2",
      choice_2: "4",
      choice_3: "6",
      choice_4: "8",
      correct_answer: "2"
    })

    card_fixture(%{
      quiz_id: quiz.id,
      format: :number_entry,
      question: "What is 1 + 1?",
      correct_answer: "2"
    })

    card_fixture(%{
      quiz_id: quiz.id,
      format: :text_entry,
      question: "How do you spell the number 1 using letters?",
      correct_answer: "one"
    })

    card_fixture(%{
      quiz_id: quiz.id,
      format: :true_or_false,
      question: "2 is larger than 1",
      correct_answer: "true"
    })

    # fetch quiz from repo so we can preload the cards
    quiz = Repo.one!(from(q in Quiz, where: q.id == ^quiz.id, preload: :cards))

    %{conn: conn, user: user, quiz: quiz}
  end

  describe "QuizTakeLive" do
    test "renders expected template", %{quiz: quiz} do
      resp_conn = build_conn() |> get(_get_quiz_take_url(quiz.id))
      assert resp_conn.status == 200
    end

    test "automatically detects display name for authenticated user", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, _view, html} = conn |> live(_get_quiz_take_url(quiz.id))

      assert html_element_has_content(
               html,
               ~s|[data-test-id="user-display-name"]|,
               user.display_name
             )
    end

    test "requires unauthenticated user to enter a display name", %{conn: conn, quiz: quiz} do
      {:ok, view, html} = conn |> logout_user() |> live(_get_quiz_take_url(quiz.id))

      # sanity check: template contains expected content
      assert html_element_has_content(
               html,
               ~s|[data-test-id="quiz-state-enter-display-name"]|,
               "Enter Your Name"
             )

      # submit the form
      display_name = "some display name"
      submitted_html = view |> form("form", %{"display-name" => display_name}) |> render_submit()

      # after user submits the form, view has correct quiz state and contains expected content
      assert html_element_has_content(
               submitted_html,
               ~s|[data-test-id="user-display-name"]|,
               display_name
             )
    end

    test "starts the quiz", %{conn: conn, quiz: quiz} do
      {:ok, view, _html} = conn |> live(_get_quiz_take_url(quiz.id))

      # click the button that starts the quiz
      submitted_html = view |> form(~s|[phx-submit="start-quiz"]|) |> render_submit()
      current_card = quiz.cards |> Enum.at(0)

      # renders expected flash message
      assert submitted_html |> html_has_flash_message(:info, "The quiz has started. Good luck!")

      # shows correct question
      assert submitted_html |> html_has_content(current_card.question)

      # shows correct choices (first card is :multiple_choice)
      assert submitted_html |> html_has_content(current_card.choice_1)
      assert submitted_html |> html_has_content(current_card.choice_2)
      assert submitted_html |> html_has_content(current_card.choice_3)
      assert submitted_html |> html_has_content(current_card.choice_4)

      # shows correct score
      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="in-progress-score"]|, "0")

      # shows correct number of questions completed
      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="current-card-index"]|, "0")

      # shows correct quiz length
      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="quiz-length"]|, length(quiz.cards))
    end

    test "handles correctly-answered questions", %{conn: conn, quiz: quiz} do
      {:ok, view, _html} = conn |> live(_get_quiz_take_url(quiz.id))

      # start the quiz
      assert view |> form(~s|[phx-submit="start-quiz"]|) |> render_submit()
      current_card = quiz.cards |> Enum.at(0)

      # submit correct answer
      submitted_html =
        view
        |> form(~s|[phx-submit="submit-user-answer"]|, %{
          "user-answer" => current_card.correct_answer
        })
        |> render_submit()

      # shows correct score
      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="in-progress-score"]|, "1")

      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="score-percent"]|, "100%")

      # shows correct number of questions completed
      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="current-card-index"]|, "1")
    end

    test "handles incorrectly-answered questions", %{conn: conn, quiz: quiz} do
      {:ok, view, _html} = conn |> live(_get_quiz_take_url(quiz.id))

      # start the quiz
      assert view |> form(~s|[phx-submit="start-quiz"]|) |> render_submit()

      # submit correct answer
      submitted_html =
        assert view
               |> form(~s|[phx-submit="submit-user-answer"]|, %{
                 # correct answer is "2"
                 "user-answer" => "4"
               })
               |> render_submit()

      # shows correct score
      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="in-progress-score"]|, "0")

      assert submitted_html |> html_element_has_content(~s|[data-test-id="score-percent"]|, "0%")

      # shows correct number of questions completed
      assert submitted_html
             |> html_element_has_content(~s|[data-test-id="current-card-index"]|, "1")
    end

    test "completes the quiz", %{conn: conn, user: user, quiz: quiz} do
      {:ok, view, _html} = conn |> live(_get_quiz_take_url(quiz.id))

      # start the quiz
      assert view |> form(~s|[phx-submit="start-quiz"]|) |> render_submit()

      # submit an answer for each question
      submitted_htmls =
        for card <- quiz.cards do
          assert view
                 |> form(~s|[phx-submit="submit-user-answer"]|, %{
                   "user-answer" => card.correct_answer
                 })
                 |> render_submit()
        end

      # template contains expected content after quiz has finished
      final_submitted_html = Enum.at(submitted_htmls, -1)

      assert final_submitted_html |> html_has_content("Quiz Complete")
      assert final_submitted_html |> html_element_has_content("button", "Play again")

      # parse final score from template
      final_score =
        final_submitted_html
        |> Floki.find(~s|[data-test-id="completed-score"]|)
        |> Floki.text()
        |> String.to_integer()

      # creates quiz record with expected content
      record = Repo.all(Record) |> Enum.at(-1)
      assert record.user_id == user.id
      assert record.quiz_id == quiz.id
      assert record.display_name == user.display_name
      assert record.card_count == length(quiz.cards)
      assert record.score == final_score
    end
  end
end
