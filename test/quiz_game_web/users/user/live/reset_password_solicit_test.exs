defmodule QuizGameWeb.Users.User.Live.ResetPasswordSolicitTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.Assertions
  import QuizGame.TestSupport.Fixtures.Users

  alias QuizGame.Users
  alias QuizGame.Repo

  describe "ResetPasswordSolicit page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/reset/password")
      assert html_has_title(html, "Reset Your Password")
    end

    test "redirects to expected route if user is already authenticated", %{conn: conn} do
      result =
        conn
        |> login_user(user_fixture())
        |> live(~p"/users/reset/password")
        |> follow_redirect(conn, ~p"/users/me")

      assert {:ok, _conn} = result
    end
  end

  describe "ResetPasswordSolicit form" do
    setup do
      %{user: user_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset/password")

      # submit the form
      {:ok, conn} =
        lv
        |> form("#user-reset-password-solicit-form", user: %{"email" => user.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      # response contains expected flash message
      assert conn_has_flash_message(conn, :info, "If your email is in our system")

      # expected record has been created
      assert Repo.get_by!(Users.UserToken, user_id: user.id).context == "password_reset"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/reset/password")

      # submit the form and follow the redirect
      {:ok, conn} =
        lv
        |> form("#user-reset-password-solicit-form", user: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      # expected record has not been created
      assert Repo.all(Users.UserToken) == []
    end
  end
end
