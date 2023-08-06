defmodule QuizGameWeb.QuizControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import QuizGame.TestSupport.{Assertions, GenericTests, QuizzesFixtures}
  import QuizGameWeb.Support.Router

  # data
  @create_attrs %{name: "test_name"}
  @update_attrs %{name: "updated_name"}
  @invalid_attrs %{name: ""}

  # setup
  defp create_quiz(_) do
    quiz = quiz_fixture()
    %{quiz: quiz}
  end

  describe "quizzes :index" do
    test "permits unauthenticated user", %{conn: conn} do
      resp_conn = get(conn, route(:quizzes, :index))
      assert html_response_has_title(resp_conn, "Quiz List")
    end
  end

  describe "quizzes :new" do
    @test_url_path route(:quizzes, :new)

    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(@test_url_path, "GET")

    test "renders expected template", %{conn: conn} do
      resp_conn = get(conn, @test_url_path)
      assert html_response_has_title(resp_conn, "Create Quiz")
    end
  end

  describe "quizzes :create" do
    @test_url_path route(:quizzes, :create)

    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(route(:quizzes, :create), "POST")

    test "creates expected record", %{conn: conn} do
      resp_conn = post(conn, @test_url_path, quiz: @create_attrs)

      # redirects to expected route
      assert %{quiz_id: quiz_id} = redirected_params(resp_conn)
      assert redirected_to(resp_conn) == route(:quizzes, :show, quiz_id: quiz_id)

      # redirected response renders expected template
      record_detail_url = route(:quizzes, :show, quiz_id: quiz_id)
      resp_conn_2 = get(resp_conn, record_detail_url)
      assert html_response_has_text(resp_conn_2, @create_attrs.name)

      # template contains new record content
      assert html_response_has_text(resp_conn_2, @create_attrs[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      resp_conn = post(conn, @test_url_path, quiz: @invalid_attrs)

      # response renders same template
      assert html_response_has_title(resp_conn, "Create Quiz")

      # response contains expected form error message(s)
      assert html_form_field_has_error_message(resp_conn.resp_body, "quiz[name]", "blank")
    end
  end

  describe "quizzes :show" do
    setup [:create_quiz]

    test "permits unauthenticated user", %{conn: conn, quiz: quiz} do
      resp_conn = get(conn, route(:quizzes, :show, quiz_id: quiz.id))
      assert resp_conn.status == 200
    end

    test "renders expected template", %{conn: conn, quiz: quiz} do
      resp_conn = get(conn, route(:quizzes, :show, quiz_id: quiz.id))
      assert html_response_has_title(resp_conn, "Quiz Info")
      assert html_response_has_text(resp_conn, quiz.name)
    end
  end

  describe "quizzes :edit" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :edit, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url_path, "GET")
    end

    test "renders record update form", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :edit, quiz_id: quiz.id)
      resp_conn = get(conn, test_url_path)
      assert html_response_has_title(resp_conn, "Edit Quiz")
    end
  end

  describe "quizzes :update" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :update, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url_path, "PUT")
    end

    test "updates expected record", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :update, quiz_id: quiz.id)
      resp_conn = put(conn, test_url_path, quiz: @update_attrs)

      # redirects to record detail
      record_detail_url = route(:quizzes, :show, quiz_id: quiz.id)
      assert redirected_to(resp_conn) == record_detail_url

      # redirect renders expected template
      resp_conn_2 = resp_conn |> get(record_detail_url)
      assert html_response_has_title(resp_conn_2, "Quiz Info")
      assert html_response_has_text(resp_conn_2, @update_attrs[:name])
    end

    test "renders errors when data is invalid", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :update, quiz_id: quiz.id)
      resp_conn = put(conn, test_url_path, quiz: @invalid_attrs)
      assert html_response_has_title(resp_conn, "Edit Quiz")
    end
  end

  describe "quizzes :delete" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :delete, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url_path, "DELETE")
    end

    test "deletes expected record", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :show, quiz_id: quiz.id)
      resp_conn = delete(conn, route(:quizzes, :delete, quiz_id: quiz.id))

      # redirects to record list
      assert redirected_to(resp_conn) == route(:quizzes, :index)

      # expected record has been deleted
      assert_error_sent 404, fn -> get(resp_conn, test_url_path) end
    end
  end
end
