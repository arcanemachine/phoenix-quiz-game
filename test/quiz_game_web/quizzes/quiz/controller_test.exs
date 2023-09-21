defmodule QuizGameWeb.Quizzes.Quiz.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}
  import QuizGameWeb.Support.Router, only: [route: 2, route: 3]

  alias QuizGame.Quizzes.Quiz

  @valid_attrs %{name: "some_name", subject: "other"}
  @valid_attrs_update %{name: "updated_name", subject: "other"}

  @name_length_max Quiz.name_length_max()

  @quiz_index_url route(:quizzes, :index)
  @quiz_create_url route(:quizzes, :create)
  @quiz_new_url route(:quizzes, :new)

  defp _get_quiz_show_url(quiz_id) do
    route(:quizzes, :show, quiz_id: quiz_id)
  end

  defp _get_quiz_edit_url(quiz_id) do
    route(:quizzes, :edit, quiz_id: quiz_id)
  end

  defp _get_quiz_update_url(quiz_id) do
    route(:quizzes, :update, quiz_id: quiz_id)
  end

  defp _get_quiz_delete_url(quiz_id) do
    route(:quizzes, :delete, quiz_id: quiz_id)
  end

  defp _create_quiz(_context) do
    user = user_fixture()
    quiz = quiz_fixture(user_id: user.id)
    %{user: user, quiz: quiz}
  end

  describe "quiz :index" do
    test "renders expected markup", %{conn: conn} do
      resp_conn = get(conn, @quiz_index_url)
      assert html_has_title(resp_conn.resp_body, "Quiz List")
    end
  end

  describe "quiz :new" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(@quiz_new_url)

    test "renders expected template", %{conn: conn} do
      resp_conn = get(conn, @quiz_new_url)
      assert html_has_title(resp_conn.resp_body, "Create Quiz")
    end
  end

  describe "quiz :create" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(@quiz_create_url, "POST")

    test "creates expected object", %{conn: conn} do
      resp_conn = post(conn, @quiz_create_url, quiz: @valid_attrs)

      # redirects to quiz :show
      assert %{quiz_id: quiz_id} = redirected_params(resp_conn)
      assert redirected_to(resp_conn) == _get_quiz_show_url(quiz_id)

      # redirected response renders expected template
      resp_conn_2 = get(resp_conn, _get_quiz_show_url(quiz_id))

      # template contains new object content
      assert html_response(resp_conn_2, 200) |> html_has_content(@valid_attrs[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ## name - blank
      resp_conn_name_blank = post(conn, @quiz_create_url, quiz: %{@valid_attrs | name: ""})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_blank.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_blank.resp_body,
               "quiz[name]",
               "required"
             )

      ## name - too long
      too_long_name = String.duplicate("x", @name_length_max + 1)

      resp_conn_name_too_long =
        post(conn, @quiz_create_url, quiz: %{@valid_attrs | name: too_long_name})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_too_long.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_too_long.resp_body,
               "quiz[name]",
               "should be at most #{@name_length_max} character(s)"
             )

      ## subject - blank
      resp_conn_subject_blank =
        post(conn, @quiz_create_url, quiz: %{@valid_attrs | subject: ""})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_subject_blank.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_subject_blank.resp_body,
               "quiz[subject]",
               "required"
             )

      ## subject - invalid choice
      resp_conn_subject_choice_invalid =
        post(conn, @quiz_create_url, quiz: %{@valid_attrs | subject: "invalid-subject"})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_subject_choice_invalid.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_subject_choice_invalid.resp_body,
               "quiz[subject]",
               "invalid"
             )
    end
  end

  describe "quiz :show" do
    setup [:_create_quiz]

    test "permits unauthenticated user", %{conn: conn, quiz: quiz} do
      resp_conn = get(conn, _get_quiz_show_url(quiz.id))
      assert resp_conn.status == 200
    end

    test "renders expected template", %{conn: conn, quiz: quiz} do
      resp_conn = get(conn, _get_quiz_show_url(quiz.id))
      assert html_has_title(resp_conn.resp_body, "Quiz Info")
      assert html_response(resp_conn, 200) |> html_has_content(quiz.name)
    end
  end

  describe "quiz :edit" do
    setup [:register_and_login_user, :_create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      quizzes_edit_url = _get_quiz_edit_url(quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, quizzes_edit_url)
    end

    test "renders object update form", %{conn: conn, user: user, quiz: quiz} do
      quizzes_edit_url = _get_quiz_edit_url(quiz.id)

      # login as quiz creator
      conn = login_user(conn, user)

      resp_conn = get(conn, quizzes_edit_url)
      assert html_has_title(resp_conn.resp_body, "Edit Quiz")
    end
  end

  describe "quiz :update" do
    setup [:register_and_login_user, :_create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      redirects_unauthenticated_user_to_login_route(conn, _get_quiz_update_url(quiz.id), "PUT")
    end

    test "updates expected object", %{conn: conn, user: user, quiz: quiz} do
      quiz_show_url = _get_quiz_show_url(quiz.id)
      quiz_update_url = _get_quiz_update_url(quiz.id)

      # login as quiz creator
      conn = login_user(conn, user)

      resp_conn = put(conn, quiz_update_url, quiz: @valid_attrs_update)

      # redirects to quiz :show
      assert redirected_to(resp_conn) == quiz_show_url

      # redirect renders expected template
      resp_conn_2 = resp_conn |> get(quiz_show_url)
      assert html_has_title(resp_conn_2.resp_body, "Quiz Info")
      assert html_response(resp_conn_2, 200) |> html_has_content(@valid_attrs_update[:name])
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, quiz: quiz} do
      quiz_update_url = _get_quiz_update_url(quiz.id)

      # login as quiz creator
      conn = login_user(conn, user)

      ## name - blank
      resp_conn_name_blank = put(conn, quiz_update_url, quiz: %{@valid_attrs | name: ""})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_blank.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_blank.resp_body,
               "quiz[name]",
               "required"
             )

      ## name - too long
      too_long_name = String.duplicate("i", @name_length_max + 1)

      resp_conn_name_too_long =
        put(conn, quiz_update_url, quiz: %{@valid_attrs | name: too_long_name})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_too_long.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_too_long.resp_body,
               "quiz[name]",
               "should be at most #{@name_length_max} character(s)"
             )
    end
  end

  describe "quiz :delete" do
    setup [:register_and_login_user, :_create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      quiz_delete_url = _get_quiz_delete_url(quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, quiz_delete_url, "DELETE")
    end

    test "deletes expected object", %{conn: conn, user: user, quiz: quiz} do
      quiz_delete_url = _get_quiz_delete_url(quiz.id)

      # login as quiz creator
      conn = login_user(conn, user)

      resp_conn = delete(conn, quiz_delete_url)

      # redirects to object index
      assert redirected_to(resp_conn) == @quiz_index_url

      # expected object has been deleted
      assert_error_sent 404, fn -> get(resp_conn, quiz_delete_url) end
    end
  end
end
