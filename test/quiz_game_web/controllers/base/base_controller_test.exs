defmodule QuizGameWeb.BaseControllerTest do
  @moduledoc false
  use QuizGameWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hello world!"
  end

  test "GET /terms-of-use", %{conn: conn} do
    conn = get(conn, ~p"/terms-of-use")
    assert html_response(conn, 200) =~ "Terms of Use"
  end

  test "GET /privacy-policy", %{conn: conn} do
    conn = get(conn, ~p"/privacy-policy")
    assert html_response(conn, 200) =~ "Privacy Policy"
  end
end
