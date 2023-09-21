defmodule QuizGameWeb.Quizzes.Live.StatsTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import Ecto.Query
  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}

  # alias QuizGameWeb.Presence
  alias QuizGame.Quizzes.Quiz
  alias QuizGame.Repo

  # @presence_topic "quiz_presence"

  defp _get_quiz_stats_url(quiz_id), do: route(:quizzes, :stats, quiz_id: quiz_id)
  defp _get_quiz_take_url(quiz_id), do: route(:quizzes, :take, quiz_id: quiz_id)

  setup %{conn: conn} do
    # create users
    user = user_fixture()
    other_user = user_fixture()

    # login primary user
    conn = conn |> login_user(user)

    # create quiz and card
    quiz = quiz_fixture(user_id: user.id)

    card_fixture(%{
      quiz_id: quiz.id,
      format: :number_entry,
      question: "What is 1 + 1?",
      correct_answer: "2"
    })

    card_fixture(%{
      quiz_id: quiz.id,
      format: :number_entry,
      question: "What is 2 + 2?",
      correct_answer: "4"
    })

    # fetch quiz from repo so we can preload the cards and easily access them
    quiz = Repo.one!(from(q in Quiz, where: q.id == ^quiz.id, preload: :cards))

    %{conn: conn, user: user, other_user: other_user, quiz: quiz}
  end

  describe "QuizTakeLive" do
    test "renders expected template for permissioned user", %{conn: conn, quiz: quiz} do
      resp_conn = conn |> get(_get_quiz_stats_url(quiz.id))
      assert resp_conn.status == 200
    end

    test "redirects unauthenticated user to login route", %{quiz: quiz} do
      assert build_conn()
             |> redirects_unauthenticated_user_to_login_route(_get_quiz_stats_url(quiz.id))
    end

    test "forbids unpermissioned user", %{other_user: other_user, quiz: quiz} do
      assert build_conn()
             |> login_user(other_user)
             |> get(_get_quiz_stats_url(quiz.id))
             |> Map.get(:status) == 403
    end

    ## presence
    test "renders expected content when no users are present", %{conn: conn, quiz: quiz} do
      {:ok, _view, html} = conn |> live(_get_quiz_stats_url(quiz.id))

      assert html =~ "No users are preparing to take this quiz."
    end

    # unauthenticated user
    test "renders expected presence data as the user progresses through the quiz", %{
      conn: conn,
      quiz: quiz
    } do
      {:ok, quiz_stats_view, html} = conn |> live(_get_quiz_stats_url(quiz.id))

      # get_presence_data = fn -> Presence.list_data_for(@presence_topic, quiz.id) end
      #
      # # sanity check - presence data has no entries
      # assert Enum.empty?(get_presence_data.())

      # stats: template contains expected content before user joins the quiz lobby
      assert html =~ "No users are preparing to take this quiz."

      ## take: unauthenticated user joins the quiz lobby
      {:ok, quiz_take_view, _html} = build_conn() |> live(_get_quiz_take_url(quiz.id))

      # # presence data now contains an entry for the user
      # assert length(get_presence_data.()) == 1

      # stats: template renders expected content since after receiving Presence data broadcast
      Process.sleep(5)
      user_joined_html = render(quiz_stats_view)

      # stats: template no longer contains initial content
      refute user_joined_html =~ "No users are preparing to take this quiz."

      # stats: template contains placeholder text for unauthenticated user with no name
      assert html_element_has_content(
               user_joined_html,
               ~s|[data-test-id="users-not-yet-started"]|,
               "No name yet"
             )

      ## take: set a display name for the user
      display_name = "Test User"

      quiz_take_view
      |> form(~s|[phx-submit="submit-display-name"]|, %{"display-name" => display_name})
      |> render_submit()

      # stats: template now contains the user's display name
      user_submit_display_name_html = render(quiz_stats_view)

      assert html_element_has_content(
               user_submit_display_name_html,
               ~s|[data-test-id="users-not-yet-started"]|,
               display_name
             )

      ## take: begin the quiz
      quiz_take_view |> form(~s|[phx-submit="start-quiz"]|) |> render_submit()

      # stats: template shows updated user status (not yet started -> in progress) and quiz stats
      user_start_quiz_html = render(quiz_stats_view)

      refute html_element_has_content(
               user_start_quiz_html,
               ~s|[data-test-id="users-not-yet-started"]|,
               display_name
             )

      assert html_element_has_content(
               user_start_quiz_html,
               ~s|[data-test-id="users-in-progress"]|,
               display_name
             )

      assert html_element_has_content(
               user_start_quiz_html,
               ~s|[data-test-id="quiz-stats"]|,
               ["0 / 0 correct", "2 remaining"]
             )

      ## take: answer the first question correctly
      correct_answer = quiz.cards |> Enum.at(0) |> Map.get(:correct_answer)

      quiz_take_view
      |> form(~s|[phx-submit="submit-user-answer"]|, %{"user-answer" => correct_answer})
      |> render_submit()

      # stats: template shows expected quiz stats
      user_answered_question_1_html = render(quiz_stats_view)

      assert html_element_has_content(
               user_answered_question_1_html,
               ~s|[data-test-id="quiz-stats"]|,
               ["100%", "1 / 1 correct", "1 remaining"]
             )

      ## take: answer the second question incorrectly (append arbitrary data to correct answer)
      quiz_take_view
      |> form(~s|[phx-submit="submit-user-answer"]|, %{"user-answer" => "some wrong answer"})
      |> render_submit()

      # stats: template shows updated user status (in progress -> completed) and quiz stats
      user_completed_html = render(quiz_stats_view)

      refute html_element_has_content(
               user_completed_html,
               ~s|[data-test-id="users-in-progress"]|,
               display_name
             )

      assert html_element_has_content(
               user_completed_html,
               ~s|[data-test-id="users-completed"]|,
               display_name
             )

      assert html_element_has_content(
               user_completed_html,
               ~s|[data-test-id="quiz-stats"]|,
               ["50%", "1 / 2 correct"]
             )

      ## take: exit the view
      GenServer.stop(quiz_take_view.pid())

      # stats: template no longer contains information about this user
      Process.sleep(5)
      user_exited_html = render(quiz_stats_view)
      refute user_exited_html =~ display_name
    end

    # other quiz
    test "does not render presence data for user who is taking another quiz", %{
      conn: conn,
      quiz: quiz
    } do
      {:ok, quiz_stats_view, html} = conn |> live(_get_quiz_stats_url(quiz.id))

      # create other quiz and card so the user can join the new quiz lobby
      other_quiz = quiz_fixture()
      _other_card = card_fixture(quiz_id: other_quiz.id)

      # stats: sanity check - template contains expected content before user joins the quiz lobby
      assert html =~ "No users are preparing to take this quiz."

      ## take: unauthenticated user joins the other quiz lobby
      {:ok, _quiz_take_view, _html} = build_conn() |> live(_get_quiz_take_url(other_quiz.id))

      # stats: template still contains initial content
      Process.sleep(5)
      user_joined_html = render(quiz_stats_view)

      assert user_joined_html =~ "No users are preparing to take this quiz."
    end
  end
end
