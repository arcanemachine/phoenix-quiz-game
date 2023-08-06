defmodule QuizGameWeb.BaseControllerTest do
  @moduledoc false
  use QuizGameWeb.ConnCase
  import QuizGame.TestSupport.Assertions

  test "GET /", %{conn: conn} do
    resp_conn = get(conn, ~p"/")
    assert html_response_has_title(resp_conn, Application.get_env(:quiz_game, :project_name))
  end

  test "GET /terms-of-use", %{conn: conn} do
    resp_conn = get(conn, ~p"/terms-of-use")
    assert html_response_has_title(resp_conn, "Terms of Use")
  end

  test "GET /privacy-policy", %{conn: conn} do
    resp_conn = get(conn, ~p"/privacy-policy")
    assert html_response_has_title(resp_conn, "Privacy Policy")
  end
end
