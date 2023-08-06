defmodule QuizGameWeb.UserRegistrationLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGameWeb.Support.Router
  import QuizGame.TestSupport.{Assertions, UsersFixtures}

  @password_length_min QuizGame.Users.User.password_length_min()
  @test_url route(:users, :registration)

  describe "Registration page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = live(conn, @test_url)

      assert html_has_title(html, "Register New Account")
    end

    test "redirects if user has already logged in", %{conn: conn} do
      result =
        conn
        |> login_user(user_fixture())
        |> live(@test_url)
        |> follow_redirect(conn, route(:users, :show))

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid 'change' event", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @test_url)

      modified_html =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "email" => "invalid email",
            "password" => "2short"
          }
        )

      # still on same page (markup has expected title)
      assert html_has_title(modified_html, "Register New Account")

      # form contains expected error messages
      assert html_form_field_has_error_message(
               modified_html,
               "user[email]",
               "is not a valid email address"
             )

      assert html_form_field_has_error_message(
               modified_html,
               "user[password]",
               "should be at least #{@password_length_min} character"
             )
    end

    test "renders errors for empty fields", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @test_url)

      modified_html =
        lv
        |> element("#registration_form")
        |> render_submit(%{user: %{"username" => "", "email" => ""}})

      # still on same page due to form errors
      assert html_has_title(modified_html, "Register New Account")

      # markup contains expected error messages
      assert html_form_field_has_error_message(modified_html, "user[username]", "blank")
      assert html_form_field_has_error_message(modified_html, "user[email]", "blank")
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @test_url)

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

      # response contains markup that is only visible to an authenticated user
      response_html = html_response(conn, 200)
      assert html_has_link(response_html, url: route(:users, :show), content: "Your profile")
      assert html_has_link(response_html, url: route(:users, :logout_confirm), content: "Logout")
    end

    test "renders errors for duplicated username", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} = live(conn, @test_url)

      modified_html =
        lv
        |> form("#registration_form", user: %{"username" => user.username})
        |> render_submit()

      # markup contains expected error message
      assert html_form_field_has_error_message(
               modified_html,
               "user[username]",
               "has already been taken"
             )
    end

    test "renders errors for duplicated email", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} = live(conn, @test_url)

      modified_html =
        lv
        |> form("#registration_form", user: %{"email" => user.email})
        |> render_submit()

      # markup contains expected error message
      assert html_form_field_has_error_message(
               modified_html,
               "user[email]",
               "has already been taken"
             )
    end
  end
end
