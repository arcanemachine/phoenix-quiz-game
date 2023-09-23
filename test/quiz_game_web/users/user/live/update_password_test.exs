defmodule QuizGameWeb.Users.User.Live.UpdatePasswordTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.Users
  import QuizGameWeb.Support.Router

  alias QuizGame.Users

  @update_password_url route(:users, :update_password)
  @password_length_min QuizGame.Users.User.password_length_min()

  describe "UpdatePassword page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = conn |> login_user(user_fixture()) |> live(@update_password_url)
      assert html_has_title(html, "Update Password")
    end

    test_redirects_unauthenticated_user_to_login_route(@update_password_url, "GET")
  end

  describe "UpdatePassword form" do
    setup %{conn: conn} do
      # register and login a user with a specific password
      password = valid_user_password()
      user = user_fixture(%{password: password})

      %{conn: login_user(conn, user), user: user, password: password}
    end

    test "updates the user's password", %{conn: conn, user: user, password: password} do
      updated_password = valid_user_password()

      # make initial request
      {:ok, lv, _html} = live(conn, @update_password_url)

      # build valid form data
      valid_form_data = %{
        "current_password" => password,
        "user" => %{
          "email" => user.email,
          "password" => updated_password,
          "password_confirmation" => updated_password
        }
      }

      # submit the form and follow the redirect
      form = form(lv, "#update-password-form", valid_form_data)
      render_submit(form)
      resp_conn = follow_trigger_action(form, conn)

      # response redirects to expected route
      assert redirected_to(resp_conn) == route(:users, :settings)

      # session has been updated with new token
      assert get_session(resp_conn, :user_token) != get_session(conn, :user_token)

      # response contains expected flash message
      assert conn_has_flash_message(resp_conn, :success, "Password updated successfully")

      # record has been updated with expected value
      assert Users.get_user_by_email_and_password(user.email, updated_password)
    end

    test "renders expected errors on 'change' event when form data is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @update_password_url)

      html_after_change =
        lv
        |> element("#update-password-form")
        |> render_change(%{
          "current_password" => "invalid_password",
          "user" => %{
            "password" => "2short",
            "password_confirmation" => "non_matching_password"
          }
        })

      # still on the same page
      assert html_has_title(html_after_change, "Update Password")

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_change,
               "user[password]",
               "should be at least #{@password_length_min} character"
             )

      assert html_form_field_has_error_message(
               html_after_change,
               "user[password_confirmation]",
               "does not match"
             )
    end

    test "renders expected errors on 'submit' event when form data is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @update_password_url)

      # submit the form
      html_after_submit =
        lv
        |> form("#update-password-form", %{
          "current_password" => "some_password",
          "user" => %{
            "password" => "2short",
            "password_confirmation" => "non_matching_password"
          }
        })
        |> render_submit()

      # still on the same page due to form error(s)
      assert html_has_title(html_after_submit, "Update Password")

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_submit,
               "user[password]",
               "should be at least #{@password_length_min} character"
             )

      assert html_form_field_has_error_message(
               html_after_submit,
               "user[password_confirmation]",
               "does not match"
             )
    end
  end

  test "redirects if user is not authenticated" do
    # initialize new request so that user
    conn = build_conn()

    # make request
    {:error, {:redirect, redirect_resp_conn}} = live(conn, @update_password_url)

    # response redirects to expected route
    assert redirect_resp_conn == %{
             flash: %{"warning" => "You must login to continue."},
             to: route(:users, :login)
           }
  end
end
