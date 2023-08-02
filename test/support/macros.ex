defmodule QuizGameWeb.TestMacros do
  @moduledoc "Test-related macros, e.g. reusable tests"

  defmacro test_redirects_unauthenticated_user_to_login_route(url, method \\ "get") do
    quote do
      test "redirects unauthenticated user to login route: #{unquote(method)}", %{conn: conn} do
        url = unquote(url)
        method = unquote(method)

        # ensure user is unauthenticated
        conn = logout_user(conn)

        # make request
        response_conn =
          case method do
            "get" -> get(conn, url)
            "post" -> post(conn, url)
            "put" -> put(conn, url)
            "patch" -> patch(conn, url)
            "delete" -> delete(conn, url)
          end

        # response returns temporary redirect to login route
        assert response_conn.status == 302
        assert get_resp_header(response_conn, "location") == [~p"/users/login"]

        # response contains expected flash message
        assert Phoenix.Flash.get(response_conn.assigns.flash, :warning) =~
                 "You must login to continue."
      end
    end
  end

  # defmacro forbids_unpermissioned_user(conn, url, method \\ "get") do
  #   quote do
  #     conn = unquote(conn)
  #     url = unquote(url)
  #     method = unquote(method)

  #     # logout and login as a new user
  #     conn = logout_user(conn)
  #     conn = register_and_login_user(%{conn: conn}) |> Map.get(:conn)

  #     # make request
  #     conn =
  #       case method do
  #         "get" -> get(conn, url)
  #         "post" -> post(conn, url)
  #         "put" -> put(conn, url)
  #         "patch" -> patch(conn, url)
  #         "delete" -> delete(conn, url)
  #       end

  #     # response has expected status code and body
  #     assert conn.status == 403
  #     assert conn.resp_body =~ "Forbidden"
  #   end
  # end
end
