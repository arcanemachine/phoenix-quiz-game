defmodule QuizGameWeb.Support.PlugTest do
  @moduledoc false
  use QuizGameWeb.ConnCase

  describe("remove_trailing_slash/2") do
    test "returns successful response when URL does not have a trailing slash", %{conn: conn} do
      conn = get(conn, "/some-url-path")

      # response does not issue a redirect
      refute conn.status == 301
    end

    test "redirects to expected route when non-root URL has a trailing slash", %{conn: conn} do
      path_with_trailing_slash = ~p"/contact-us/"
      expected_url_path = ~p"/contact-us"

      conn = get(conn, path_with_trailing_slash)

      # returns permanent redirect to expected path
      assert conn.status == 301
      assert get_resp_header(conn, "location") == [expected_url_path]
    end
  end
end
