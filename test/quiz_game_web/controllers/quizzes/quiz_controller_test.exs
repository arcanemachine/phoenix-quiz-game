defmodule QuizGameWeb.Quizzes.QuizControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import QuizGame.TestSupport.{Assertions, GenericTests, QuizzesFixtures}
  import QuizGameWeb.Support.Router, only: [route: 2, route: 3]

  alias QuizGame.Quizzes.Quiz

  @valid_attrs %{name: "some_name"}
  @valid_attrs_update %{name: "updated_name"}

  @name_length_max Quiz.name_length_max()

  # setup
  defp create_quiz(_context) do
    quiz = quiz_fixture()
    %{quiz: quiz}
  end

  describe "quizzes :index" do
    test "renders expected markup", %{conn: conn} do
      resp_conn = get(conn, route(:quizzes, :index))
      assert html_has_title(resp_conn.resp_body, "Quiz List")
    end
  end

  describe "quizzes :new" do
    setup [:register_and_login_user]

    @test_url_path route(:quizzes, :new)

    test_redirects_unauthenticated_user_to_login_route(@test_url_path, "GET")

    test "renders expected template", %{conn: conn} do
      resp_conn = get(conn, @test_url_path)
      assert html_has_title(resp_conn.resp_body, "Create Quiz")
    end
  end

  describe "quizzes :create" do
    setup [:register_and_login_user]

    @test_url_path route(:quizzes, :create)

    test_redirects_unauthenticated_user_to_login_route(route(:quizzes, :create), "POST")

    test "creates expected record", %{conn: conn} do
      resp_conn = post(conn, @test_url_path, quiz: @valid_attrs)

      # redirects to expected route
      assert %{quiz_id: quiz_id} = redirected_params(resp_conn)
      assert redirected_to(resp_conn) == route(:quizzes, :show, quiz_id: quiz_id)

      # redirected response renders expected template
      record_detail_url = route(:quizzes, :show, quiz_id: quiz_id)
      resp_conn_2 = get(resp_conn, record_detail_url)

      # template contains new record content
      assert html_response(resp_conn_2, 200) |> html_has_content(@valid_attrs[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ## name - blank
      resp_conn_name_blank = post(conn, @test_url_path, quiz: %{@valid_attrs | name: ""})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_blank.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_blank.resp_body,
               "quiz[name]",
               "blank"
             )

      ## name - too long
      too_long_name = String.duplicate("i", @name_length_max + 1)

      resp_conn_name_too_long =
        post(conn, @test_url_path, quiz: %{@valid_attrs | name: too_long_name})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_too_long.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_too_long.resp_body,
               "quiz[name]",
               "should be at most #{@name_length_max} character(s)"
             )
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
      assert html_has_title(resp_conn.resp_body, "Quiz Info")
      assert html_response(resp_conn, 200) |> html_has_content(quiz.name)
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
      assert html_has_title(resp_conn.resp_body, "Edit Quiz")
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
      resp_conn = put(conn, test_url_path, quiz: @valid_attrs_update)

      # redirects to record detail
      record_detail_url = route(:quizzes, :show, quiz_id: quiz.id)
      assert redirected_to(resp_conn) == record_detail_url

      # redirect renders expected template
      resp_conn_2 = resp_conn |> get(record_detail_url)
      assert html_has_title(resp_conn_2.resp_body, "Quiz Info")
      assert html_response(resp_conn_2, 200) |> html_has_content(@valid_attrs_update[:name])
    end

    test "renders errors when data is invalid", %{conn: conn, quiz: quiz} do
      test_url_path = route(:quizzes, :update, quiz_id: quiz.id)

      ## name - blank
      resp_conn_name_blank = put(conn, test_url_path, quiz: %{@valid_attrs | name: ""})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_blank.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_blank.resp_body,
               "quiz[name]",
               "blank"
             )

      ## name - too long
      too_long_name = String.duplicate("i", @name_length_max + 1)

      resp_conn_name_too_long =
        put(conn, test_url_path, quiz: %{@valid_attrs | name: too_long_name})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_too_long.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_too_long.resp_body,
               "quiz[name]",
               "should be at most #{@name_length_max} character(s)"
             )
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

      # redirects to record index
      assert redirected_to(resp_conn) == route(:quizzes, :index)

      # expected record has been deleted
      assert_error_sent 404, fn -> get(resp_conn, test_url_path) end
    end
  end
end
