defmodule QuizGameWeb.QuizControllerTest do
  @moduledoc false
  use QuizGameWeb.ConnCase

  import QuizGame.QuizzesFixtures
  import QuizGameWeb.GenericTests
  import QuizGameWeb.Router.Paths

  # data
  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  # setup
  defp create_quiz(_) do
    quiz = quiz_fixture()
    %{quiz: quiz}
  end

  describe "quizzes :index" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(route_path("quizzes", :index), "GET")

    test "lists all quizzes", %{conn: conn} do
      response_conn = get(conn, route_path("quizzes", :index))
      assert html_response(response_conn, 200) =~ "Listing Quizzes"
    end
  end

  describe "quizzes :new" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(route_path("quizzes", :new), "GET")

    test "renders object creation form", %{conn: conn} do
      response_conn = get(conn, route_path("quizzes", :new))
      assert html_response(response_conn, 200) =~ "New Quiz"
    end
  end

  describe "quizzes :create" do
    setup [:register_and_login_user]

    test_redirects_unauthenticated_user_to_login_route(route_path("quizzes", :create), "POST")

    test "redirects to object detail route when data is valid", %{conn: conn} do
      test_url = route_path("quizzes", :create)
      response_conn = post(conn, test_url, quiz: @create_attrs)

      # redirects to expected route
      assert %{quiz_id: quiz_id} = redirected_params(response_conn)
      assert redirected_to(response_conn) == route_path("quizzes", :show, quiz_id: quiz_id)

      # redirect renders expected template
      object_detail_url = route_path("quizzes", :show, quiz_id: quiz_id)
      response_conn_2 = get(response_conn, object_detail_url)
      assert html_response(response_conn_2, 200) =~ "Quiz #{quiz_id}"

      # template contains new object content
      assert html_response(response_conn_2, 200) =~ "#{@create_attrs[:name]}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      test_url = route_path("quizzes", :create)
      response_conn = post(conn, test_url, quiz: @invalid_attrs)

      assert html_response(response_conn, 200) =~ "New Quiz"
    end
  end

  describe "quizzes :edit" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url = route_path("quizzes", :edit, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url, "GET")
    end

    test "renders object update form", %{conn: conn, quiz: quiz} do
      test_url = route_path("quizzes", :edit, quiz_id: quiz.id)
      response_conn = get(conn, test_url)

      assert html_response(response_conn, 200) =~ "Edit Quiz"
    end
  end

  describe "quizzes :update" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url = route_path("quizzes", :update, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url, "PUT")
    end

    test "redirects to expected route when data is valid", %{conn: conn, quiz: quiz} do
      test_url = route_path("quizzes", :update, quiz_id: quiz.id)
      response_conn = put(conn, test_url, quiz: @update_attrs)

      # redirects to object detail
      object_detail_url = route_path("quizzes", :show, quiz_id: quiz.id)
      assert redirected_to(response_conn) == object_detail_url

      # redirect renders expected template
      response_conn_2 = response_conn |> get(object_detail_url)
      assert html_response(response_conn_2, 200) =~ "some updated name"

      # template contains new object content
      assert html_response(response_conn_2, 200) =~ "#{@update_attrs[:name]}"
    end

    test "renders errors when data is invalid", %{conn: conn, quiz: quiz} do
      test_url = route_path("quizzes", :update, quiz_id: quiz.id)
      response_conn = put(conn, test_url, quiz: @invalid_attrs)

      assert html_response(response_conn, 200) =~ "Edit Quiz"
    end
  end

  describe "quizzes :delete" do
    setup [:register_and_login_user, :create_quiz]

    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      test_url = route_path("quizzes", :delete, quiz_id: quiz.id)
      redirects_unauthenticated_user_to_login_route(conn, test_url, "DELETE")
    end

    test "deletes chosen quiz", %{conn: conn, quiz: quiz} do
      test_url = route_path("quizzes", :show, quiz_id: quiz.id)
      response_conn = delete(conn, route_path("quizzes", :delete, quiz_id: quiz.id))

      # redirects to object list
      assert redirected_to(response_conn) == route_path("quizzes", :index)

      # expected object has been deleted
      assert_error_sent 404, fn -> get(response_conn, test_url) end
    end
  end
end
