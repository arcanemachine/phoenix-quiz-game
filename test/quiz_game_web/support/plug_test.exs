defmodule QuizGameWeb.Support.PlugTest do
  @moduledoc false
  use QuizGameWeb.ConnCase

  describe("remove_trailing_slash/2") do
    test "returns successful response when URL does not have a trailing slash", %{conn: conn} do
      test_path = ~p"/terms-of-use"

      conn = get(conn, test_path)

      # returns successful response
      assert html_response(conn, 200)
    end

    test "redirects to expected route when non-root URL has a trailing slash", %{conn: conn} do
      test_path = ~p"/terms-of-use/"
      expected_path = ~p"/terms-of-use"

      conn = get(conn, test_path)

      # returns permanent redirect to expected path
      assert conn.status == 301
      assert get_resp_header(conn, "location") == [expected_path]
    end
  end
end
