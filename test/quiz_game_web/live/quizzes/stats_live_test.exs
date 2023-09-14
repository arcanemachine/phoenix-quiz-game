defmodule QuizGameWeb.Quizzes.StatsLiveTest do
  @moduledoc false
  use QuizGameWeb.ConnCase
  import QuizGame.TestSupport.{QuizzesFixtures, UsersFixtures}

  defp _get_stats_live_url(quiz_id), do: route(:quizzes, :stats, quiz_id: quiz_id)

  setup %{conn: conn} do
    user = user_fixture()
    conn = conn |> login_user(user)

    # create quiz and card
    quiz = quiz_fixture(user_id: user.id)

    card_fixture(%{
      quiz_id: quiz.id,
      format: :number_entry,
      question: "What is 1 + 1?",
      correct_answer: "2"
    })

    %{conn: conn, user: user, quiz: quiz}
  end

  describe "QuizTakeLive" do
    test "renders expected template", %{conn: conn, quiz: quiz} do
      resp_conn = conn |> get(_get_stats_live_url(quiz.id))
      assert resp_conn.status == 200
    end
  end
end
