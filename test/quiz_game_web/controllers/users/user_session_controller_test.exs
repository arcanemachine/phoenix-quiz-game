defmodule QuizGameWeb.UserSessionControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import QuizGame.TestSupport.{Assertions, UsersFixtures}
  import QuizGameWeb.Support.Router

  setup do
    %{user: user_fixture()}
  end

  describe "users:register_success GET" do
    @register_success_url route(:users, :register_success)

    test "shows expected flash message and redirects to expected route", %{conn: conn} do
      conn = get(conn, @register_success_url)

      # response redirects to expected route
      assert redirected_to(conn) == route(:users, :login)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~
               "Account created successfully. You may now log in."
    end
  end

  describe "users:create POST" do
    @login_url route(:users, :login)

    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, @login_url, %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      # response redirects to expected route
      assert redirected_to(conn) == route(:users, :show)

      # response contains expected session data
      assert get_session(conn, :user_token)

      # make a request as a logged-in user and check for logged-in menu items
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ route(:users, :show)
      assert response =~ route(:users, :logout)
    end

    test "logs the user in with session persistence", %{conn: conn, user: user} do
      conn =
        post(conn, @login_url, %{
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
        |> post(@login_url, %{
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
        |> post(@login_url, %{
          "_action" => "password-updated",
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

    test "redirects to login page when form submitted with invalid credentials", %{conn: conn} do
      conn =
        post(conn, @login_url, %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      # response redirects to expected route
      assert redirected_to(conn) == @login_url

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
    end
  end

  describe "users:show GET" do
    @users_show_url route(:users, :show)

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(@users_show_url)
      assert resp_conn |> html_response(200) |> html_has_title("Your Profile")
    end
  end

  describe "users:logout DELETE" do
    @users_show_url route(:users, :logout)

    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> post(@users_show_url)

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = post(conn, @users_show_url)

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/"

      # response contains expected session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Logged out successfully"
    end
  end
end
