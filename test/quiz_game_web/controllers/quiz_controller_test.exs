defmodule QuizGameWeb.QuizControllerTest do
  @moduledoc false
  use QuizGameWeb.ConnCase

  import QuizGame.QuizzesFixtures
  import QuizGameWeb.TestMacros

  alias QuizGame.UsersFixtures

  # data
  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def url_quiz_index, do: ~p"/quizzes"
  def url_quiz_new, do: ~p"/quizzes/new"
  def url_quiz_create, do: ~p"/quizzes"
  def url_quiz_show(%{id: id}), do: ~p"/quizzes/#{id}"
  def url_quiz_edit(%{id: id}), do: ~p"/quizzes/#{id}/edit"
  def url_quiz_update(%{id: id}), do: ~p"/quizzes/#{id}"
  def url_quiz_delete(%{id: id}), do: ~p"/quizzes/#{id}"
  def url_users_login, do: ~p"/users/login"

  # setup
  defp create_quiz(_) do
    quiz = quiz_fixture()
    %{quiz: quiz}
  end

  setup do
    %{user: UsersFixtures.user_fixture()}
  end

  describe "quizzes :index" do
    test_redirects_unauthenticated_user_to_login_route(url_quiz_index(), "GET")

    test "lists all quizzes", %{conn: conn, user: user} do
      response_conn = conn |> login_user(user) |> get(url_quiz_index())
      assert html_response(response_conn, 200) =~ "Listing Quizzes"
    end
  end

  describe "quizzes :new" do
    test_redirects_unauthenticated_user_to_login_route(url_quiz_new(), "GET")

    test "renders form", %{conn: conn, user: user} do
      response_conn = conn |> login_user(user) |> get(url_quiz_new())
      assert html_response(response_conn, 200) =~ "New Quiz"
    end
  end

  describe "quizzes :create" do
    test_redirects_unauthenticated_user_to_login_route(url_quiz_create(), "POST")

    test "redirects to expected route when data is valid", %{conn: conn, user: user} do
      response_conn = conn |> login_user(user) |> post(url_quiz_create(), quiz: @create_attrs)

      # redirects to expected route
      assert %{id: id} = redirected_params(response_conn)
      assert redirected_to(response_conn) == url_quiz_show(%{id: id})

      # redirect renders expected template
      response_conn_2 = get(response_conn, url_quiz_show(%{id: id}))
      assert html_response(response_conn_2, 200) =~ "Quiz #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      response_conn = conn |> login_user(user) |> post(url_quiz_create(), quiz: @invalid_attrs)
      assert html_response(response_conn, 200) =~ "New Quiz"
    end
  end

  describe "quizzes :edit" do
    setup [:create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      response_conn = conn |> get(url_quiz_edit(%{id: quiz.id}))

      assert response_conn.status == 302
      assert get_resp_header(response_conn, "location") == [url_users_login()]
    end

    test "renders form for editing chosen quiz", %{conn: conn, user: user, quiz: quiz} do
      response_conn = conn |> login_user(user) |> get(url_quiz_edit(%{id: quiz.id}))
      assert html_response(response_conn, 200) =~ "Edit Quiz"
    end
  end

  describe "quizzes :update" do
    setup [:create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      response_conn = conn |> get(url_quiz_update(%{id: quiz.id}))

      assert response_conn.status == 302
      assert get_resp_header(response_conn, "location") == [url_users_login()]
    end

    test "redirects to expected route when data is valid", %{conn: conn, user: user, quiz: quiz} do
      response_conn =
        conn |> login_user(user) |> put(url_quiz_update(%{id: quiz.id}), quiz: @update_attrs)

      # redirects to expected route
      assert redirected_to(response_conn) == url_quiz_show(%{id: quiz.id})

      # redirect renders expected template
      response_conn_2 = response_conn |> get(url_quiz_show(%{id: quiz.id}))
      assert html_response(response_conn_2, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, quiz: quiz} do
      response_conn =
        conn |> login_user(user) |> put(url_quiz_update(%{id: quiz.id}), quiz: @invalid_attrs)

      assert html_response(response_conn, 200) =~ "Edit Quiz"
    end
  end

  describe "quizzes :delete" do
    setup [:create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      response_conn = conn |> get(url_quiz_delete(%{id: quiz.id}))

      assert response_conn.status == 302
      assert get_resp_header(response_conn, "location") == [url_users_login()]
    end

    test "deletes chosen quiz", %{conn: conn, user: user, quiz: quiz} do
      response_conn = conn |> login_user(user) |> delete(url_quiz_delete(%{id: quiz.id}))

      # redirects to object list
      assert redirected_to(response_conn) == url_quiz_index()

      # expected object has been deleted
      assert_error_sent 404, fn ->
        get(response_conn, url_quiz_show(%{id: quiz.id}))
      end
    end
  end
end
