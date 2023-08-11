defmodule QuizGameWeb.UserRegistrationLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGameWeb.Support.Router
  import QuizGame.TestSupport.{Assertions, UsersFixtures}

  @test_url_path route(:users, :register)
  @password_length_min QuizGame.Users.User.password_length_min()

  describe "UserRegistrationLive page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = live(conn, @test_url_path)
      assert html_has_title(html, "Register New Account")
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

  describe "UserRegistrationLive form" do
    test "creates account and logs the user in when form data is valid", %{conn: conn} do
      valid_attrs = valid_user_attributes()

      # make initial request
      {:ok, lv, html} = live(conn, @test_url_path)

      # sanity check: response does not contain markup that should only visible to an
      # authenticated user
      refute html_has_link(html, url: route(:users, :show), content: "Your profile")
      refute html_has_link(html, url: route(:users, :logout_confirm), content: "Logout")

      # submit the form and follow the redirect
      form_data = %{
        "user" =>
          Map.merge(
            valid_attrs,
            %{password_confirmation: valid_attrs.password}
          )
      }

      form = form(lv, "#registration_form", form_data)
      render_submit(form)
      resp_conn = follow_trigger_action(form, conn)

      # response redirects to expected route
      assert redirected_to(resp_conn) == route(:users, :show)

      # make a request as the logged-in user
      resp_conn_2 = get(resp_conn, ~p"/")

      # response contains markup that is only visible to an authenticated user
      result_html = html_response(resp_conn_2, 200)
      assert html_has_link(result_html, url: route(:users, :show), content: "Your profile")
      assert html_has_link(result_html, url: route(:users, :logout_confirm), content: "Logout")
    end

    test "renders expected errors on 'change' event when form data is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @test_url_path)

      html_after_change =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "email" => "invalid email",
            "password" => "2short"
          }
        )

      # still on same page due to errors in form
      assert html_has_title(html_after_change, "Register New Account")

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_change,
               "user[email]",
               "is not a valid email address"
             )

      assert html_form_field_has_error_message(
               html_after_change,
               "user[password]",
               "should be at least #{@password_length_min} character"
             )
    end

    test "renders expected errors on 'submit' event with blank form fields", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @test_url_path)

      # submit the form
      html_after_submit =
        lv
        |> element("#registration_form")
        |> render_submit(%{user: %{"username" => "", "email" => ""}})

      # still on same page due to form error(s)
      assert html_has_title(html_after_submit, "Register New Account")

      # form has expected error message(s)
      assert html_form_field_has_error_message(html_after_submit, "user[username]", "blank")
      assert html_form_field_has_error_message(html_after_submit, "user[email]", "blank")
    end

    test "renders expected errors on 'submit' event if username has already been taken", %{
      conn: conn
    } do
      user = user_fixture()

      {:ok, lv, _html} = live(conn, @test_url_path)

      html_after_submit =
        lv
        |> form("#registration_form", user: %{"username" => user.username})
        |> render_submit()

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_submit,
               "user[username]",
               "has already been taken"
             )
    end

    test "renders expected errors on 'submit' event if email has already been taken", %{
      conn: conn
    } do
      user = user_fixture()

      {:ok, lv, _html} = live(conn, @test_url_path)

      html_after_submit =
        lv
        |> form("#registration_form", user: %{"email" => user.email})
        |> render_submit()

      # form has expected error message
      assert html_form_field_has_error_message(
               html_after_submit,
               "user[email]",
               "has already been taken"
             )
    end
  end
end
