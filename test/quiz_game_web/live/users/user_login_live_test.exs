defmodule QuizGameWeb.UserLoginLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGameWeb.Support.Router
  import QuizGame.TestSupport.{Assertions, UsersFixtures}

  @test_url_path route(:users, :login)

  describe "UserLoginLive page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = live(conn, @test_url_path)

      assert html_has_title(html, "Login")

      assert html_has_link(html,
               url: route(:users, :register),
               content: "Register new account"
             )

      assert html_has_link(html,
               url: route(:users, :reset_password),
               content: "Forgot your password?"
             )
    end

    test "redirects authenticated user to expected route", %{conn: conn} do
      result =
        conn
        |> login_user(user_fixture())
        |> live(@test_url_path)
        |> follow_redirect(conn, route(:users, :show))

      assert {:ok, _conn} = result
    end
  end

  describe "UserLoginLive form" do
    test "submitted with valid credentials", %{conn: conn} do
      password = "valid_password"
      user = user_fixture(%{password: password})

      # make initial request
      {:ok, lv, _html} = live(conn, @test_url_path)

      # submit form data
      form_data = [user: %{email: user.email, password: password, remember_me: true}]
      form = form(lv, "#login_form", form_data)
      resp_conn = submit_form(form, conn)

      # redirects to expected route
      assert redirected_to(resp_conn) == route(:users, :show)
    end

    test "redirects to expected page with expected message if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, @test_url_path)

      # submit the form and follow the redirect
      form_data = [
        user: %{email: "non_existent_user@example.com", password: "non_existent_password"}
      ]

      form = form(lv, "#login_form", form_data)
      resp_conn = submit_form(form, conn)

      # response has expected error message
      assert Phoenix.Flash.get(resp_conn.assigns.flash, :error) == "Invalid email or password"

      # response redirects to expected route
      assert redirected_to(resp_conn) == @test_url_path
    end
  end

  describe "UserLoginLive navigation" do
    test "redirects to UserResetPasswordLive when the 'Forgot Password' button is clicked", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, route(:users, :login))

      # simulate event on expected element
      {:ok, conn} =
        lv
        |> element(~s|a:fl-contains("Forgot your password?")|)
        |> render_click()
        |> follow_redirect(conn, route(:users, :reset_password))

      # response has expected title
      assert html_has_title(conn.resp_body, "Reset Your Password")
    end
  end
end
