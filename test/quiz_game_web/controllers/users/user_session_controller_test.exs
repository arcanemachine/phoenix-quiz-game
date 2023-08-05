defmodule QuizGameWeb.UserSessionControllerTest do
  @moduledoc false
  use QuizGameWeb.ConnCase, async: true
  import QuizGame.UsersFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /users/login" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/login", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/users/me"

      # response contains expected session data
      assert get_session(conn, :user_token)

      # make a request as a logged-in user and check for logged-in menu items
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ ~p"/users/me"
      assert response =~ ~p"/users/logout"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/users/me"

      # response contains expected cookie
      assert conn.resp_cookies["_quiz_game_web_user_remember_me"]
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      conn =
        conn
        # add redirect data to session
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/users/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      # response redirects to specified route
      assert redirected_to(conn) == "/foo/bar"

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged in successfully"
    end

    test "user is automatically logged in after registering an account", %{conn: conn, user: user} do
      conn =
        conn
        |> post(~p"/users/login", %{
          "_action" => "registered",
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/users/me"

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, user: user} do
      conn =
        conn
        |> post(~p"/users/login", %{
          "_action" => "password_updated",
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/users/me/update"

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/users/login", %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/users/login"

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
    end
  end

  describe "DELETE /users/logout" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> post(~p"/users/logout")

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = post(conn, ~p"/users/logout")

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end
  end
end
