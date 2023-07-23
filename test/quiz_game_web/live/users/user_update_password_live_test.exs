defmodule QuizGameWeb.UserUpdatePasswordLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  alias QuizGame.Users
  import Phoenix.LiveViewTest
  import QuizGame.UsersFixtures

  describe "page" do
    test "renders page without error", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> login_user(user_fixture())
        |> live(~p"/users/me/update/password")

      assert html =~ "Update Password"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/me/update/password")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/login"
      assert %{"warning" => "You must login to continue."} = flash
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})
      %{conn: login_user(conn, user), user: user, password: password}
    end

    test "updates the user password", %{conn: conn, user: user, password: password} do
      new_password = valid_user_password()

      {:ok, lv, _html} = live(conn, ~p"/users/me/update/password")

      form_input = %{
        "current_password" => password,
        "user" => %{
          "email" => user.email,
          "password" => new_password,
          "password_confirmation" => new_password
        }
      }

      form = form(lv, "#password_form", form_input)

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/users/me/update"

      assert get_session(new_password_conn, :user_token) != get_session(conn, :user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :success) =~
               "Password updated successfully"

      assert Users.get_user_by_email_and_password(user.email, new_password)
    end

    @tag fixme: true
    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/password")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "badpassword",
          "user" => %{
            "password" => "2short",
            "password_confirmation" => "does not match"
          }
        })

      # still on the same page due to form errors
      assert result =~ "Update Password"

      assert result =~
               "should be at least #{QuizGame.Users.User.password_length_min()} character"

      assert result =~ "does not match"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/password")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "user" => %{
            "password" => "2short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      # assert result =~ "Update Password"
      assert result =~
               "should be at least #{QuizGame.Users.User.password_length_min()} character"

      assert result =~ "does not match"
    end
  end

  test "redirects if user is not logged in" do
    conn = build_conn()
    {:error, redirect} = live(conn, ~p"/users/me/update/password")
    assert {:redirect, %{to: path, flash: flash}} = redirect
    assert path == ~p"/users/login"
    assert %{"warning" => message} = flash
    assert message == "You must login to continue."
  end
end
