defmodule QuizGameWeb.Users.Live.RegisterTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.Assertions
  import QuizGame.TestSupport.Fixtures.Users
  import QuizGameWeb.Support.Router

  @register_url route(:users, :register)
  @password_length_min QuizGame.Users.User.password_length_min()

  describe "User registration page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _view, html} = live(conn, @register_url)
      assert html_has_title(html, "Register New Account")
    end

    test "redirects authenticated user to expected route", %{conn: conn} do
      result =
        conn
        |> login_user(user_fixture())
        |> live(@register_url)
        |> follow_redirect(conn, route(:users, :show))

      assert {:ok, _conn} = result
    end
  end

  describe "User registration form" do
    test "creates account and logs the user in when form data is valid", %{conn: conn} do
      valid_attrs = valid_user_attributes()

      # make initial request
      {:ok, view, html} = live(conn, @register_url)

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

      assert form(view, "#user-registration-form", form_data)
             # user is redirected to users:register_success
             |> render_submit() == {:error, {:redirect, %{to: route(:users, :register_success)}}}
    end

    test "renders expected errors on 'change' event when form data is invalid", %{conn: conn} do
      {:ok, view, _html} = live(conn, @register_url)

      html_after_change =
        view
        |> element("#user-registration-form")
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
      {:ok, view, _html} = live(conn, @register_url)

      # submit the form
      html_after_submit =
        view
        |> element("#user-registration-form")
        |> render_submit(%{user: %{"username" => "", "display_name" => "", "email" => ""}})

      # still on same page due to form error(s)
      assert html_has_title(html_after_submit, "Register New Account")

      # form has expected error message(s)
      assert html_form_field_has_error_message(html_after_submit, "user[username]", "required")

      assert html_form_field_has_error_message(
               html_after_submit,
               "user[display_name]",
               "required"
             )

      assert html_form_field_has_error_message(html_after_submit, "user[email]", "required")
    end

    test "renders expected errors on 'submit' event if username has already been taken", %{
      conn: conn
    } do
      user = user_fixture()

      {:ok, view, _html} = live(conn, @register_url)

      html_after_submit =
        view
        |> form("#user-registration-form", user: %{"username" => user.username})
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

      {:ok, view, _html} = live(conn, @register_url)

      html_after_submit =
        view
        |> form("#user-registration-form", user: %{"email" => user.email})
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
