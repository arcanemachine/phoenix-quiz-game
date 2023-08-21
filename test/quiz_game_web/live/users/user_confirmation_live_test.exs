defmodule QuizGameWeb.UserConfirmationLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, UsersFixtures}
  import QuizGameWeb.Support.Router

  alias QuizGame.Users
  alias QuizGame.Repo

  def test_url_path(opts), do: route(:users, :verify_email_confirm, token: opts[:token])

  setup do
    %{user: user_fixture()}
  end

  describe "UserConfirmationLive page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = live(conn, test_url_path(token: "some_token"))
      assert html_has_title(html, "Confirm Your Email")
    end
  end

  describe "UserConfirmationLive form" do
    test "does not confirm a given token more than once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Users.deliver_email_verify_instructions(user, url)
        end)

      test_url_path = test_url_path(token: token)

      # make initial request
      {:ok, lv, _html} = live(conn, test_url_path)

      # submit the form and follow the redirect
      {:ok, resp_conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, route(:users, :show))

      # response contains expected flash message
      assert conn_has_flash_message(resp_conn, :success, "Your email address has been confirmed.")

      # the users's email address is now confirmed
      assert Users.get_user!(user.id).confirmed_at

      # user token has been removed from session data
      refute get_session(resp_conn, :user_token)

      # no user tokens have been saved in the database
      assert Repo.all(Users.UserToken) == []

      ## does not confirm email more than once - with unauthenticated user
      {:ok, lv, _html} = live(conn, test_url_path)

      # submit the form
      {:ok, resp_conn_2} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert conn_has_flash_message(
               resp_conn_2,
               :error,
               "Email confirmation link is invalid, expired, or has already been used."
             )

      ## does not confirm email more than once - with authenticated user
      {:ok, lv, _html} = build_conn() |> login_user(user) |> live(test_url_path)

      # submit the form and follow the redirect
      {:ok, resp_conn_3} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, route(:users, :show))

      # response contains expected flash message
      assert conn_has_flash_message(
               resp_conn_3,
               :info,
               "Your email address has already been confirmed."
             )
    end

    test "does not confirm email address if token is invalid", %{conn: conn, user: user} do
      # make request
      {:ok, lv, _html} = live(conn, test_url_path(token: "invalid_token"))

      # submit the form and follow the redirect
      {:ok, resp_conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      # response contains expected flash message
      assert conn_has_flash_message(
               resp_conn,
               :error,
               "Email confirmation link is invalid, expired, or has already been used."
             )

      # email address has not been confirmed
      refute Users.get_user!(user.id).confirmed_at
    end
  end
end
