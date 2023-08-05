defmodule QuizGameWeb.QuizControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import QuizGame.QuizzesFixtures
  import QuizGameWeb.Support.Router
  import QuizGameWeb.TestSupport.{Assertions, GenericTests}

  # data
  @create_attrs %{name: "test_name"}
  @update_attrs %{name: "updated_name"}
  @invalid_attrs %{name: nil}

  # setup
  defp create_quiz(_) do
    quiz = quiz_fixture()
    %{quiz: quiz}
  end

  describe "quizzes :index" do
    test "lists all quizzes", %{conn: conn} do
      response_conn = get(conn, route("quizzes", :index))
      assert html_response_has_title(response_conn, "Quiz List")
    end
  end

  describe "quizzes :new" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(route("quizzes", :new), "GET")

    test "renders expected template", %{conn: conn} do
      response_conn = get(conn, route("quizzes", :new))
      assert html_response_has_title(response_conn, "Create Quiz")
    end
  end

  describe "quizzes :create" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(route("quizzes", :create), "POST")

    test "creates expected record", %{conn: conn} do
      test_url = route("quizzes", :create)
      response_conn = post(conn, test_url, quiz: @create_attrs)

      # redirects to expected route
      assert %{quiz_id: quiz_id} = redirected_params(response_conn)
      assert redirected_to(response_conn) == route("quizzes", :show, quiz_id: quiz_id)

      # redirect renders expected template
      record_detail_url = route("quizzes", :show, quiz_id: quiz_id)
      response_conn_2 = get(response_conn, record_detail_url)
      assert html_response_has_text(response_conn_2, "Quiz #{quiz_id}")

      # template contains new record content
      assert html_response_has_text(response_conn_2, @create_attrs[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      test_url = route("quizzes", :create)
      response_conn = post(conn, test_url, quiz: @invalid_attrs)

      assert html_response_has_title(response_conn, "Create Quiz")
    end
  end

  describe "quizzes :show" do
    setup [:create_quiz]

    test "renders expected template", %{conn: conn, quiz: quiz} do
      response_conn = get(conn, route("quizzes", :show, quiz_id: quiz.id))
      assert html_response_has_title(response_conn, "Quiz Info")
    end
  end

  describe "quizzes :edit" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url = route("quizzes", :edit, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url, "GET")
    end

    test "renders record update form", %{conn: conn, quiz: quiz} do
      test_url = route("quizzes", :edit, quiz_id: quiz.id)
      response_conn = get(conn, test_url)

      assert html_response_has_title(response_conn, "Edit Quiz")
    end
  end

  describe "quizzes :update" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url = route("quizzes", :update, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url, "PUT")
    end

    test "updates expected record", %{conn: conn, quiz: quiz} do
      test_url = route("quizzes", :update, quiz_id: quiz.id)
      response_conn = put(conn, test_url, quiz: @update_attrs)

      # redirects to record detail
      record_detail_url = route("quizzes", :show, quiz_id: quiz.id)
      assert redirected_to(response_conn) == record_detail_url

      # redirect renders expected template
      response_conn_2 = response_conn |> get(record_detail_url)
      assert html_response_has_title(response_conn_2, "Quiz Info")
      assert html_response_has_text(response_conn_2, @update_attrs[:name])
    end

    test "renders errors when data is invalid", %{conn: conn, quiz: quiz} do
      test_url = route("quizzes", :update, quiz_id: quiz.id)
      response_conn = put(conn, test_url, quiz: @invalid_attrs)

      assert html_response_has_title(response_conn, "Edit Quiz")
    end
  end

  describe "quizzes :delete" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url = route("quizzes", :delete, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url, "DELETE")
    end

    test "deletes expected record", %{conn: conn, quiz: quiz} do
      test_url = route("quizzes", :show, quiz_id: quiz.id)
      response_conn = delete(conn, route("quizzes", :delete, quiz_id: quiz.id))

      # redirects to record list
      assert redirected_to(response_conn) == route("quizzes", :index)

      # expected record has been deleted
      assert_error_sent 404, fn -> get(response_conn, test_url) end
    end
  end
end
