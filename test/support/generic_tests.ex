defmodule QuizGameWeb.TestSupport.GenericTests do
  @moduledoc "This project's generic/reusable tests."
  use QuizGameWeb.ConnCase

  @doc """
  Use this test for routes for which:
    - Authentication is required, and
    - Unauthenticated users should be redirected to the login page.

  If the route contains a URL that is known before runtime (ie. doesn't contain any dynamic
  parameters, such as an record ID), then you probably just want to use the complementary
  macro instead.
  """
  def redirects_unauthenticated_user_to_login_route(conn, url, http_method) do
    # ensure user is unauthenticated
    conn = logout_user(conn)

    # make request
    response_conn =
      case http_method do
        "GET" -> get(conn, url)
        "POST" -> post(conn, url)
        "PUT" -> put(conn, url)
        "PATCH" -> patch(conn, url)
        "DELETE" -> delete(conn, url)
      end

    # response contains temporary redirect to login route
    assert response_conn.status == 302
    assert get_resp_header(response_conn, "location") == [~p"/users/login"]

    # response contains expected flash message
    assert Phoenix.Flash.get(response_conn.assigns.flash, :warning) =~
             "You must login to continue."
  end

  @doc """
  A macro that wraps the 'auth-required' test functionality into a single line.

  Use this function if the route under test does not have any dynamic parameters (e.g. record
  ID) in the URL.
  """
  defmacro test_redirects_unauthenticated_user_to_login_route(url, http_method) do
    quote do
      test "redirects unauthenticated user to login route: #{unquote(http_method)}", %{conn: conn} do
        redirects_unauthenticated_user_to_login_route(conn, unquote(url), unquote(http_method))
      end
    end
  end

  # defmacro forbids_unpermissioned_user(conn, url, http_method) do
  #   quote do
  #     conn = unquote(conn)
  #     url = unquote(url)
  #     http_method = unquote(http_method)

  #     # logout and login as a new user
  #     conn = logout_user(conn)
  #     conn = register_and_login_user(%{conn: conn}) |> Map.get(:conn)

  #     # make request
  #     conn =
  #       case http_method do
  #         "GET" -> get(conn, url)
  #         "POST" -> post(conn, url)
  #         "PUT" -> put(conn, url)
  #         "PATCH" -> patch(conn, url)
  #         "DELETE" -> delete(conn, url)
  #       end

  #     # response has expected status code and body
  #     assert conn.status == 403
  #     assert conn.resp_body =~ "Forbidden"
  #   end
  # end
end
