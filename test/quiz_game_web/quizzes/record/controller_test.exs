defmodule QuizGameWeb.Quizzes.Record.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Ecto.Query
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}

  alias QuizGame.Quizzes.Quiz
  alias QuizGame.Repo

  setup %{conn: conn} do
    # create users
    user = user_fixture()
    other_user = user_fixture()

    # create quiz and records
    quiz = quiz_fixture(user_id: user.id)
    record_fixture(%{quiz_id: quiz.id})
    record_fixture(%{quiz_id: quiz.id})

    # fetch quiz from repo so we can preload the records and easily access them
    quiz = Repo.one!(from(q in Quiz, where: q.id == ^quiz.id, preload: :records))

    %{conn: conn, user: user, other_user: other_user, quiz: quiz}
  end

  describe "quiz :index" do
    test "renders expected markup for permissioned user", %{conn: conn, user: user, quiz: quiz} do
      other_record = record_fixture()

      html =
        conn |> login_user(user) |> get(~p"/quizzes/#{quiz.id}/records") |> Map.get(:resp_body)

      assert html_has_title(html, "Quiz Records")
      assert html_has_content(html, quiz.name)

      # template contains expected quiz records
      for record <- quiz.records do
        assert html_has_content(html, record.display_name)
      end

      refute html_has_content(html, other_record.display_name)
    end

    test "redirects unauthenticated user to login route", %{quiz: quiz} do
      assert build_conn()
             |> redirects_unauthenticated_user_to_login_route(~p"/quizzes/#{quiz.id}/records")
    end

    test "forbids unpermissioned user", %{other_user: other_user, quiz: quiz} do
      assert build_conn()
             |> login_user(other_user)
             |> get(~p"/quizzes/#{quiz.id}/records")
             |> Map.get(:status) == 403
    end
  end
end
