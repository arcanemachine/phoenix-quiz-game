defmodule QuizGameWeb.Users.Session.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import QuizGame.TestSupport.Assertions
  import QuizGame.TestSupport.Fixtures.Users
  import QuizGameWeb.Support.Router

  @user_register_success_url route(:users, :register_success)
  @user_login_url route(:users, :login)
  @user_logout_url route(:users, :logout)

  setup do
    %{user: user_fixture()}
  end

  describe "user_session :register_success" do
    test "shows expected flash message and redirects to expected route", %{conn: conn} do
      conn = get(conn, @user_register_success_url)

      # response redirects to expected route
      assert redirected_to(conn) == route(:users, :login)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~
               "Account created successfully. You may now log in."
    end
  end

  describe "user_session :create" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, @user_login_url, %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      # response redirects to expected route
      assert redirected_to(conn) == route(:users, :show)

      # response contains expected session data
      assert get_session(conn, :user_token)

      # make a request as a logged-in user and check for logged-in menu items
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ route(:users, :show)
      assert response =~ route(:users, :logout)
    end

    test "logs the user in with session persistence", %{conn: conn, user: user} do
      conn =
        post(conn, @user_login_url, %{
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
        |> post(@user_login_url, %{
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
        |> post(@user_login_url, %{
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
        post(conn, @user_login_url, %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      # response redirects to expected route
      assert redirected_to(conn) == @user_login_url

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
    end
  end

  describe "user_session :logout_confirm" do
    test "renders expected content", %{conn: conn, user: user} do
      html = conn |> get(@user_logout_url) |> Map.get(:resp_body)
      assert html_has_title(html, "Confirm Logout")

      # shows expected content for logged-in user
      logged_in_html = conn |> login_user(user) |> get(@user_logout_url) |> Map.get(:resp_body)
      assert html_has_content(logged_in_html, "Are you sure you want to log out?")

      # shows expected content for logged-out user
      logged_out_html = build_conn() |> get(@user_logout_url) |> Map.get(:resp_body)
      assert html_has_content(logged_out_html, "You are already logged out.")
    end
  end

  describe "user_session :logout" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> post(@user_logout_url)

      # response redirects to expected route
      assert redirected_to(conn) == "/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = post(conn, @user_logout_url)

      # response redirects to expected route
      assert redirected_to(conn) == "/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end
  end
end
