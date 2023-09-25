defmodule QuizGameWeb.Users.User.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import Ecto.Query
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}

  alias QuizGame.Repo
  alias QuizGame.Users.User

  # setup
  setup do
    %{user: user_fixture()}
  end

  describe "users :show" do
    test_redirects_unauthenticated_user_to_login_route(~p"/users/me", "GET")

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(~p"/users/me")
      assert html_has_title(resp_conn.resp_body, "Your Profile")
    end
  end

  describe "users :settings" do
    test_redirects_unauthenticated_user_to_login_route(~p"/users/me/update", "GET")

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(~p"/users/me/update")
      assert html_has_title(resp_conn.resp_body, "Manage Your Account")
    end
  end

  describe "users :delete_confirm" do
    test_redirects_unauthenticated_user_to_login_route(~p"/users/me/delete", "GET")

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(~p"/users/me/delete")
      assert html_has_title(resp_conn.resp_body, "Delete Your Account")
    end
  end

  describe "users :delete" do
    test_redirects_unauthenticated_user_to_login_route(~p"/users/me/delete", "POST")

    test "deletes expected user", %{conn: conn, user: user} do
      # get initial record count before deletion
      get_user_count = fn -> Repo.one(from u in "users", select: count(u.id)) end
      initial_record_count = get_user_count.()

      # make request
      resp_conn = conn |> login_user(user) |> post(~p"/users/me/delete")

      # response contains expected flash message
      assert conn_has_flash_message(
               resp_conn,
               :success,
               "Account deleted successfully"
             )

      # expected record has been deleted
      assert_raise Ecto.NoResultsError, fn ->
        Repo.get!(User, user.id)
      end

      # record count has decreased by one
      assert get_user_count.() == initial_record_count - 1
    end
  end

  describe "users :quizzes_index" do
    test_redirects_unauthenticated_user_to_login_route(~p"/users/me/quizzes", "GET")

    test "renders expected content", %{conn: conn, user: user} do
      # create quizzes
      user_quiz = quiz_fixture(%{user_id: user.id})
      other_user_quiz = quiz_fixture(%{user_id: user_fixture().id})

      # renders expected template
      html = conn |> login_user(user) |> get(~p"/users/me/quizzes") |> Map.get(:resp_body)
      assert html_has_title(html, "Your Quizzes")

      # contains user quiz content
      assert html_has_content(html, user_quiz.name)

      # does not contain quiz content created by other user
      refute html_has_content(html, other_user_quiz.name)
    end
  end

  describe "users :records_index" do
    test_redirects_unauthenticated_user_to_login_route(~p"/users/me/quizzes/records", "GET")

    test "renders expected content", %{conn: conn, user: user} do
      # create records
      quiz = quiz_fixture()
      record_fixture(%{quiz_id: quiz.id, user_id: user.id})

      other_quiz = quiz_fixture()
      record_fixture(%{quiz_id: other_quiz.id, user_id: user_fixture().id})

      # renders expected template
      html = conn |> login_user(user) |> get(~p"/users/me/quizzes/records") |> Map.get(:resp_body)
      assert html_has_title(html, "Your Quiz Records")

      # contains user's quiz record content
      assert html_has_content(html, quiz.name)

      # does not contain other user's record content
      refute html_has_content(html, other_quiz.name)
    end
  end
end
