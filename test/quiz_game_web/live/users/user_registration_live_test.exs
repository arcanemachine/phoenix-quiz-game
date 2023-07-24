defmodule QuizGameWeb.UserRegistrationLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.UsersFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Register"
      assert html =~ "Login"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> login_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/users/me")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces", "password" => "2short"})

      assert result =~ "Register"
      assert result =~ "is not a valid email address"
      assert result =~ "should be at least 8 character"
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      # build valid set of attributes
      attrs = valid_user_attributes()

      # add password_confirmation field
      attrs = %{"user" => Map.merge(attrs, %{password_confirmation: attrs.password})}

      # build the form
      form = form(lv, "#registration_form", attrs)

      # submit the form
      render_submit(form)

      # get a response
      conn = follow_trigger_action(form, conn)

      # response redirects to expected route
      assert redirected_to(conn) == ~p"/users/me"

      # make a request as the logged-in user
      conn = get(conn, "/")

      # response contains expected status code and body content
      response = html_response(conn, 200)
      assert response =~ "Your profile"
      assert response =~ "Logout"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the login button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|a:fl-contains("Login to an existing account")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/login")

      assert login_html =~ "Login"
    end
  end
end
