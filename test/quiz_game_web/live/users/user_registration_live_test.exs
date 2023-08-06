defmodule QuizGameWeb.UserRegistrationLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGameWeb.Support.Router
  import QuizGame.TestSupport.{Assertions, UsersFixtures}

  @test_url route(:users, :registration)
  @password_length_min QuizGame.Users.User.password_length_min()

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

      # submit form data
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

  describe "User registration form" do
    test "creates account and logs the user in", %{conn: conn} do
      valid_attrs = valid_user_attributes()

      # make initial request
      {:ok, lv, html} = live(conn, @test_url)

      # sanitch check: response does not contain markup that should only visible to an
      # authenticated user
      refute html_has_link(html, url: route(:users, :show), content: "Your profile")
      refute html_has_link(html, url: route(:users, :logout_confirm), content: "Logout")

      # submit valid form
      form_data = %{
        "user" =>
          Map.merge(
            valid_attrs,
            %{password_confirmation: valid_attrs.password}
          )
      }

      form = form(lv, "#registration_form", form_data)
      render_submit(form)
      response_conn = follow_trigger_action(form, conn)

      # response redirects to expected route
      assert redirected_to(response_conn) == route(:users, :show)

      # make a request as the logged-in user
      response_conn_2 = get(response_conn, ~p"/")

      # response contains markup that is only visible to an authenticated user
      result_html = html_response(response_conn_2, 200)
      assert html_has_link(result_html, url: route(:users, :show), content: "Your profile")
      assert html_has_link(result_html, url: route(:users, :logout_confirm), content: "Logout")
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
