defmodule QuizGameWeb.Core.ControllerTest do
  @moduledoc false
  use QuizGameWeb.ConnCase
  import QuizGame.TestSupport.Assertions

  test "GET /", %{conn: conn} do
    resp_conn = get(conn, "/")
    assert html_has_title(resp_conn.resp_body, Application.get_env(:quiz_game, :project_name))
  end

  test "GET /terms-of-use", %{conn: conn} do
    resp_conn = get(conn, route(:core, :terms_of_use))
    assert html_has_title(resp_conn.resp_body, "Terms of Use")
  end

  test "GET /privacy-policy", %{conn: conn} do
    resp_conn = get(conn, route(:core, :privacy_policy))
    assert html_has_title(resp_conn.resp_body, "Privacy Policy")
  end
end
