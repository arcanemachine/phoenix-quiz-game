defmodule QuizGameWeb.UserUpdateEmailLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  alias QuizGame.Users
  import Phoenix.LiveViewTest
  import QuizGame.UsersFixtures

  describe "page" do
    test "renders expected page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> login_user(user_fixture())
        |> live(~p"/users/me/update/email")

      assert html =~ "Update Email"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/me/update/email")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/login"
      assert %{"warning" => "You must login to continue."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})
      %{conn: login_user(conn, user), user: user, password: password}
    end

    test "updates the user email", %{conn: conn, password: password, user: user} do
      new_email = unique_user_email()

      {:ok, lv, _html} = live(conn, ~p"/users/me/update/email")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "user" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "Almost done! Check your email inbox for a confirmation link."
      assert Users.get_user_by_email(user.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/email")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "user" => %{"email" => "with spaces"}
        })

      # still on same page due to form errors
      assert result =~ "Update Email"

      assert result =~ "is not a valid email address"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/email")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "user" => %{"email" => user.email}
        })
        |> render_submit()

      assert result =~ "Update Email"
      assert result =~ "should be different than your current email"
      assert result =~ "should be your current password"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Users.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{conn: login_user(conn, user), token: token, email: email, user: user}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      {:error, redirect} = live(conn, ~p"/users/me/update/email/confirm/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/me"
      assert %{"success" => message} = flash
      assert message == "Email updated successfully"
      refute Users.get_user_by_email(user.email)
      assert Users.get_user_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/users/me/update/email/confirm/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/me"
      assert %{"error" => message} = flash
      assert message == "Email update link is invalid or expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      {:error, redirect} = live(conn, ~p"/users/me/update/email/confirm/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/me"
      assert %{"error" => message} = flash
      assert message == "Email update link is invalid or expired"
      assert Users.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/users/me/update/email/confirm/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/login"
      assert %{"warning" => message} = flash
      assert message == "You must login to continue."
    end
  end
end
