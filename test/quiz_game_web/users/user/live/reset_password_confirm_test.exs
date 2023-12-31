defmodule QuizGameWeb.Users.User.Live.ResetPasswordConfirmTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.Assertions
  import QuizGame.TestSupport.Fixtures.Users

  alias QuizGame.Users

  @password_length_min QuizGame.Users.User.password_length_min()

  setup do
    # create user and token
    user = user_fixture()

    token =
      extract_user_token(fn url ->
        Users.deliver_password_reset_instructions(user, url)
      end)

    %{token: token, user: user}
  end

  describe "ResetPasswordConfirm page" do
    test "renders expected markup", %{conn: conn, token: token} do
      {:ok, _lv, html} = live(conn, ~p"/users/reset-password/#{token}")
      assert html_has_title(html, "Set New Password")
    end

    test "returns expected redirect when password reset token is invalid", %{conn: conn} do
      {:error, {:redirect, redirect_resp_conn}} =
        live(conn, ~p"/users/reset-password/invalid-token")

      # redirect contains expected values
      assert redirect_resp_conn == %{
               flash: %{
                 "error" => "Reset password link is invalid, expired, or has already been used."
               },
               to: "/"
             }
    end
  end

  describe "ResetPasswordConfirm form" do
    test "resets password once when form data is valid", %{conn: conn, token: token, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset-password/#{token}")

      # submit the form and follow the redirect
      {:ok, conn} =
        lv
        |> form("#user-reset-password-confirm-form",
          user: %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/users/login")

      # user token has been removed from session data
      refute get_session(conn, :user_token)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~ "Password reset successfully"
      assert Users.get_user_by_email_and_password(user.email, "new valid password")

      # password reset link is now expired (request now redirects to expected route)
      {:error, {:redirect, redirect_resp_conn}} =
        live(conn, ~p"/users/reset-password/#{token}")

      assert redirect_resp_conn == %{
               flash: %{
                 "error" => "Reset password link is invalid, expired, or has already been used."
               },
               to: "/"
             }
    end

    test "renders expected errors on 'change' event when form data is invalid", %{
      conn: conn,
      token: token
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/reset-password/#{token}")

      # submit the form
      html_after_change =
        lv
        |> element("#user-reset-password-confirm-form")
        |> render_change(user: %{"password" => "2short", "confirmation_password" => "short"})

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

    test "does not reset password when form data is invalid", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset-password/#{token}")

      html_after_submit =
        lv
        |> form("#user-reset-password-confirm-form",
          user: %{
            "password" => "2short",
            "password_confirmation" => "non_matching_password"
          }
        )
        |> render_submit()

      # still on same page due to errors in form
      assert html_has_title(html_after_submit, "Set New Password")

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
end
