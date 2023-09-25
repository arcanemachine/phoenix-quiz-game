defmodule QuizGameWeb.Users.Session.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import QuizGame.TestSupport.Assertions
  import QuizGame.TestSupport.Fixtures.Users

  setup do
    %{user: user_fixture()}
  end

  describe "user_session :register_success" do
    test "shows expected flash message and redirects to expected route", %{conn: conn} do
      conn = get(conn, ~p"/users/register/success")

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/users/login"

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~
               "Account created successfully. You may now log in."
    end
  end

  describe "user_session :create" do
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
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ ~p"/users/me"
      assert response =~ ~p"/users/logout"
    end

    test "logs the user in with session persistence", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      # response contains expected cookie
      assert conn.resp_cookies["_quiz_game_web_user_remember_me"]
    end

    test "logs the user then redirects via session 'user_return_to'", %{conn: conn, user: user} do
      conn =
        conn
        # add redirect data to session
        |> init_test_session(user_return_to: "/test-url")
        |> post(~p"/users/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      # response redirects to specified route
      assert redirected_to(conn) == "/test-url"

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged in successfully"
    end

    test "logs in automatically after updating the user's password", %{conn: conn, user: user} do
      conn =
        conn
        |> post(~p"/users/login", %{
          "_action" => "password-updated",
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      # response redirects to expected route
      assert redirected_to(conn) == "/users/me/update"

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Password updated successfully"
    end

    test "redirects to login page when form submitted with invalid credentials", %{conn: conn} do
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

  describe "user_session :logout_confirm" do
    test "renders expected content", %{conn: conn, user: user} do
      html = conn |> get(~p"/users/logout") |> Map.get(:resp_body)
      assert html_has_title(html, "Confirm Logout")

      # shows expected content for logged-in user
      logged_in_html = conn |> login_user(user) |> get(~p"/users/logout") |> Map.get(:resp_body)
      assert html_has_content(logged_in_html, "Are you sure you want to log out?")

      # shows expected content for logged-out user
      logged_out_html = build_conn() |> get(~p"/users/logout") |> Map.get(:resp_body)
      assert html_has_content(logged_out_html, "You are already logged out.")
    end
  end

  describe "user_session :logout" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> post(~p"/users/logout")

      # response redirects to expected route
      assert redirected_to(conn) == "/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = post(conn, ~p"/users/logout")

      # response redirects to expected route
      assert redirected_to(conn) == "/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end
  end
end
