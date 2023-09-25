defmodule QuizGameWeb.Quizzes.Quiz.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}

  alias QuizGame.Quizzes.Quiz

  @valid_attrs %{name: "some_name", subject: "other"}
  @valid_attrs_update %{name: "updated_name", subject: "other"}

  @name_length_max Quiz.name_length_max()

  defp _create_quiz(_context) do
    user = user_fixture()
    quiz = quiz_fixture(user_id: user.id)
    %{user: user, quiz: quiz}
  end

  describe "quiz :index" do
    test "renders expected markup", %{conn: conn} do
      quiz = quiz_fixture()

      html = get(conn, ~p"/quizzes") |> Map.get(:resp_body)
      assert html_has_title(html, "Quiz List")

      # template contains quiz information
      assert html_has_content(html, quiz.name)
    end
  end

  describe "quiz :index_subject" do
    test "renders expected markup for valid subject", %{conn: conn} do
      math_quiz = quiz_fixture(%{name: "some math quiz", subject: :math})
      science_quiz = quiz_fixture(%{name: "some science quiz", subject: :science})

      # renders expected markup
      html = get(conn, ~p"/quizzes/subjects/math") |> Map.get(:resp_body)
      assert html_has_title(html, "Math Quizzes")

      # shows expected quiz for this subject
      assert html_has_content(html, math_quiz.name)

      # does not show quiz for a different subject
      refute html_has_content(html, science_quiz.name)
    end

    test "returns 404 for non-existent subject", %{conn: conn} do
      assert_raise(QuizGameWeb.Support.Exceptions.HttpResponse, "Not Found", fn ->
        get(conn, ~p"/quizzes/subjects/invalid-subject")
      end)
    end
  end

  describe "quiz :new" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(~p"/quizzes/create")

    test "renders expected template", %{conn: conn} do
      resp_conn = get(conn, ~p"/quizzes/create")
      assert html_has_title(resp_conn.resp_body, "Create Quiz")
    end
  end

  describe "quiz :create" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(~p"/quizzes/create", "POST")

    test "creates expected object", %{conn: conn} do
      resp_conn = post(conn, ~p"/quizzes/create", quiz: @valid_attrs)

      # redirects to quiz :show
      assert %{quiz_id: quiz_id} = redirected_params(resp_conn)
      assert redirected_to(resp_conn) == ~p"/quizzes/#{quiz_id}"

      # redirected response renders expected template
      resp_conn_2 = get(resp_conn, ~p"/quizzes/#{quiz_id}")

      # template contains new object content
      assert html_response(resp_conn_2, 200) |> html_has_content(@valid_attrs[:name])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      ## name - blank
      resp_conn_name_blank = post(conn, ~p"/quizzes/create", quiz: %{@valid_attrs | name: ""})

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
        post(conn, ~p"/quizzes/create", quiz: %{@valid_attrs | name: too_long_name})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_name_too_long.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_name_too_long.resp_body,
               "quiz[name]",
               "should be at most #{@name_length_max} character(s)"
             )

      ## subject - blank
      resp_conn_subject_blank =
        post(conn, ~p"/quizzes/create", quiz: %{@valid_attrs | subject: ""})

      # form has expected error message(s)
      assert html_form_has_errors(resp_conn_subject_blank.resp_body)

      assert html_form_field_has_error_message(
               resp_conn_subject_blank.resp_body,
               "quiz[subject]",
               "required"
             )

      ## subject - invalid choice
      resp_conn_subject_choice_invalid =
        post(conn, ~p"/quizzes/create", quiz: %{@valid_attrs | subject: "invalid-subject"})

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
      resp_conn = get(conn, ~p"/quizzes/#{quiz.id}")
      assert resp_conn.status == 200
    end

    test "renders expected template", %{conn: conn, quiz: quiz} do
      resp_conn = get(conn, ~p"/quizzes/#{quiz.id}")
      assert html_has_title(resp_conn.resp_body, "Quiz Info")
      assert html_response(resp_conn, 200) |> html_has_content(quiz.name)
    end
  end

  describe "quiz :edit" do
    setup [:register_and_login_user, :_create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      quizzes_edit_url = ~p"/quizzes/#{quiz.id}/update"
      redirects_unauthenticated_user_to_login_route(conn, quizzes_edit_url)
    end

    test "renders object update form", %{conn: conn, user: user, quiz: quiz} do
      quizzes_edit_url = ~p"/quizzes/#{quiz.id}/update"

      # login as quiz creator
      conn = login_user(conn, user)

      resp_conn = get(conn, quizzes_edit_url)
      assert html_has_title(resp_conn.resp_body, "Edit Quiz")
    end
  end

  describe "quiz :update" do
    setup [:register_and_login_user, :_create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      redirects_unauthenticated_user_to_login_route(conn, ~p"/quizzes/#{quiz.id}/update", "PUT")
    end

    test "updates expected object", %{conn: conn, user: user, quiz: quiz} do
      # login as quiz creator
      conn = login_user(conn, user)

      resp_conn = put(conn, ~p"/quizzes/#{quiz.id}/update", quiz: @valid_attrs_update)

      # redirects to quiz :show
      assert redirected_to(resp_conn) == ~p"/quizzes/#{quiz.id}"

      # redirect renders expected template
      resp_conn_2 = resp_conn |> get(~p"/quizzes/#{quiz.id}")
      assert html_has_title(resp_conn_2.resp_body, "Quiz Info")
      assert html_response(resp_conn_2, 200) |> html_has_content(@valid_attrs_update[:name])
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, quiz: quiz} do
      # login as quiz creator
      conn = login_user(conn, user)

      ## name - blank
      resp_conn_name_blank =
        put(conn, ~p"/quizzes/#{quiz.id}/update", quiz: %{@valid_attrs | name: ""})

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
        put(conn, ~p"/quizzes/#{quiz.id}/update", quiz: %{@valid_attrs | name: too_long_name})

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
      redirects_unauthenticated_user_to_login_route(
        conn,
        ~p"/quizzes/#{quiz.id}/delete",
        "DELETE"
      )
    end

    test "deletes expected object", %{conn: conn, user: user, quiz: quiz} do
      # login as quiz creator
      conn = login_user(conn, user)

      resp_conn = delete(conn, ~p"/quizzes/#{quiz.id}/delete")

      # redirects to object index
      assert redirected_to(resp_conn) == ~p"/quizzes"

      # expected object has been deleted
      assert_error_sent 404, fn -> get(resp_conn, ~p"/quizzes/#{quiz.id}") end
    end
  end
end
