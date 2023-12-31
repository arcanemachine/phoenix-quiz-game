defmodule QuizGameWeb.Users.User.Live.UpdateEmailTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.Users

  alias QuizGame.Users

  describe "UpdateEmail page" do
    test_redirects_unauthenticated_user_to_login_route(~p"/users/me/update/email", "GET")

    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = conn |> login_user(user_fixture()) |> live(~p"/users/me/update/email")
      assert html_has_title(html, "Update Email")
    end
  end

  describe "UpdateEmail form" do
    setup %{conn: conn} do
      # register and login a user with a specific password
      password = valid_user_password()
      user = user_fixture(%{password: password})

      %{conn: login_user(conn, user), user: user, password: password}
    end

    test "updates the user's email address", %{conn: conn, password: password, user: user} do
      new_email = unique_user_email()

      # make initial request
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/email")

      # build valid form data
      valid_form_data = %{
        "current_password" => password,
        "user" => %{"email" => new_email}
      }

      # submit the form
      html_after_submit =
        lv
        |> form("#user-update-email-form", valid_form_data)
        |> render_submit()

      # markup contains expected flash message
      assert html_has_flash_message(
               html_after_submit,
               :info,
               "Almost done! Check your email inbox for a confirmation link."
             )

      # user record still contains initial email address (user must open confirmation email before
      # value will be updated in the database)
      assert Users.get_user_by_email(user.email)
    end

    test "renders expected errors on 'change' event when form data is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/email")

      # change the form
      html_after_change =
        lv
        |> element("#user-update-email-form")
        |> render_change(%{
          "action" => "email_update",
          "current_password" => "some_password",
          "user" => %{"email" => "invalid email"}
        })

      # still on same page
      assert html_has_title(html_after_change, "Update Email")

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_change,
               "user[email]",
               "is not a valid email address"
             )
    end

    test "renders expected errors on 'submit' event when form data is invalid", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/email")

      # submit the form
      html_after_submit =
        lv
        |> form("#user-update-email-form", %{
          "current_password" => "incorrect_password",
          "user" => %{"email" => user.email}
        })
        |> render_submit()

      # still on same page due to form error(s)
      assert html_has_title(html_after_submit, "Update Email")

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_submit,
               "user[email]",
               "should be different than your current email"
             )

      assert html_form_field_has_error_message(
               html_after_submit,
               "current_password",
               "should be your current password"
             )
    end
  end

  describe "UpdateEmail confirmation process" do
    setup %{conn: conn} do
      # register and login user with a specific password and a new email address to update to
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Users.deliver_email_update_instructions(%{user | email: email}, user.email, url)
        end)

      %{conn: login_user(conn, user), token: token, email: email, user: user}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      # make request to password confirmation route
      {:error, {:live_redirect, redirect_resp_conn}} =
        live(conn, ~p"/users/me/update/email/#{token}")

      # live redirect contains expected values
      assert redirect_resp_conn == %{
               flash: %{"success" => "Email updated successfully"},
               to: ~p"/users/me"
             }

      # record has been updated in the database
      refute Users.get_user_by_email(user.email)
      assert Users.get_user_by_email(email)

      # try to use email confirmation token again
      {:error, {:live_redirect, redirect_resp_conn_2}} =
        live(conn, ~p"/users/me/update/email/#{token}")

      # live redirect contains expected values
      assert redirect_resp_conn_2 == %{
               flash: %{
                 "error" => "Email update link is invalid, expired, or has already been used."
               },
               to: ~p"/users/me"
             }
    end

    test "does not update email if token is invalid", %{conn: conn, user: user} do
      # make request to password confirmation route
      {:error, {:live_redirect, redirect_resp_conn}} =
        live(conn, ~p"/users/me/update/email/INVALID_TOKEN")

      # live redirect contains expected values
      assert redirect_resp_conn == %{
               flash: %{
                 "error" => "Email update link is invalid, expired, or has already been used."
               },
               to: ~p"/users/me"
             }

      # user's email address is unchanged
      assert Users.get_user_by_email(user.email)
    end

    test "redirects unauthenticated user to expected route even if token is valid", %{
      token: token
    } do
      # create new request as unauthenticated user
      conn = build_conn()

      # make request to password confirmation route
      {:error, {:redirect, redirect_resp_conn}} =
        live(conn, ~p"/users/me/update/email/#{token}")

      # redirect contains expected values
      assert redirect_resp_conn == %{
               flash: %{"warning" => "You must login to continue."},
               to: ~p"/users/login"
             }
    end
  end
end
