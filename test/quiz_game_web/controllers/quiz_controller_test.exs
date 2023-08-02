defmodule QuizGameWeb.QuizControllerTest do
  use QuizGameWeb.ConnCase

  import QuizGame.QuizzesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all quizzes", %{conn: conn} do
      conn = get(conn, ~p"/quizzes")
      assert html_response(conn, 200) =~ "Listing Quizzes"
    end
  end

  describe "new quiz" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/quizzes/new")
      assert html_response(conn, 200) =~ "New Quiz"
    end
  end

  describe "create quiz" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/quizzes", quiz: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/quizzes/#{id}"

      conn = get(conn, ~p"/quizzes/#{id}")
      assert html_response(conn, 200) =~ "Quiz #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/quizzes", quiz: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Quiz"
    end
  end

  describe "edit quiz" do
    setup [:create_quiz]

    test "renders form for editing chosen quiz", %{conn: conn, quiz: quiz} do
      conn = get(conn, ~p"/quizzes/#{quiz}/edit")
      assert html_response(conn, 200) =~ "Edit Quiz"
    end
  end

  describe "update quiz" do
    setup [:create_quiz]

    test "redirects when data is valid", %{conn: conn, quiz: quiz} do
      conn = put(conn, ~p"/quizzes/#{quiz}", quiz: @update_attrs)
      assert redirected_to(conn) == ~p"/quizzes/#{quiz}"

      conn = get(conn, ~p"/quizzes/#{quiz}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, quiz: quiz} do
      conn = put(conn, ~p"/quizzes/#{quiz}", quiz: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Quiz"
    end
  end

  describe "delete quiz" do
    setup [:create_quiz]

    test "deletes chosen quiz", %{conn: conn, quiz: quiz} do
      conn = delete(conn, ~p"/quizzes/#{quiz}")
      assert redirected_to(conn) == ~p"/quizzes"

      assert_error_sent 404, fn ->
        get(conn, ~p"/quizzes/#{quiz}")
      end
    end
  end

  defp create_quiz(_) do
    quiz = quiz_fixture()
    %{quiz: quiz}
  end
end
