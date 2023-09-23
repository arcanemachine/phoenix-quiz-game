defmodule QuizGameWeb.Users.User.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import Ecto.Query
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}
  import QuizGameWeb.Support.Router

  alias QuizGame.Repo
  alias QuizGame.Users.User

  @user_show_url route(:users, :show)
  @user_settings_url route(:users, :settings)
  @user_delete_confirm_url route(:users, :delete_confirm)
  @user_delete_url route(:users, :delete_confirm)
  @user_quizzes_index_url route(:users, :quizzes_index)
  @user_records_index_url route(:users, :records_index)

  # setup
  setup do
    %{user: user_fixture()}
  end

  describe "users :show" do
    test_redirects_unauthenticated_user_to_login_route(@user_show_url, "GET")

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(@user_show_url)
      assert html_has_title(resp_conn.resp_body, "Your Profile")
    end
  end

  describe "users :settings" do
    test_redirects_unauthenticated_user_to_login_route(@user_settings_url, "GET")

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(@user_settings_url)
      assert html_has_title(resp_conn.resp_body, "Manage Your Account")
    end
  end

  describe "users :delete_confirm" do
    test_redirects_unauthenticated_user_to_login_route(@user_delete_confirm_url, "GET")

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(@user_delete_url)
      assert html_has_title(resp_conn.resp_body, "Delete Your Account")
    end
  end

  describe "users :delete" do
    @user_delete_url route(:users, :delete_confirm)

    test_redirects_unauthenticated_user_to_login_route(@user_delete_url, "POST")

    test "deletes expected user", %{conn: conn, user: user} do
      # get initial record count before deletion
      get_user_count = fn -> Repo.one(from u in "users", select: count(u.id)) end
      initial_record_count = get_user_count.()

      # make request
      resp_conn = conn |> login_user(user) |> post(@user_delete_url)

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
    test_redirects_unauthenticated_user_to_login_route(@user_quizzes_index_url, "GET")

    test "renders expected content", %{conn: conn, user: user} do
      # create quizzes
      user_quiz = quiz_fixture(%{user_id: user.id})
      other_user_quiz = quiz_fixture(%{user_id: user_fixture().id})

      # renders expected template
      html = conn |> login_user(user) |> get(@user_quizzes_index_url) |> Map.get(:resp_body)
      assert html_has_title(html, "Your Quizzes")

      # contains user quiz content
      assert html_has_content(html, user_quiz.name)

      # does not contain quiz content created by other user
      refute html_has_content(html, other_user_quiz.name)
    end
  end

  describe "users :records_index" do
    test_redirects_unauthenticated_user_to_login_route(@user_records_index_url, "GET")

    test "renders expected content", %{conn: conn, user: user} do
      # create records
      quiz = quiz_fixture()
      record_fixture(%{quiz_id: quiz.id, user_id: user.id})

      other_quiz = quiz_fixture()
      record_fixture(%{quiz_id: other_quiz.id, user_id: user_fixture().id})

      # renders expected template
      html = conn |> login_user(user) |> get(@user_records_index_url) |> Map.get(:resp_body)
      assert html_has_title(html, "Your Quiz Records")

      # contains user's quiz record content
      assert html_has_content(html, quiz.name)

      # does not contain other user's record content
      refute html_has_content(html, other_quiz.name)
    end
  end
end
