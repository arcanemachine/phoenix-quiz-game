defmodule QuizGameWeb.UserConfirmationLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, UsersFixtures}
  import QuizGameWeb.Support.Router

  alias QuizGame.Users
  alias QuizGame.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "renders expected template", %{conn: conn} do
      test_url = route(:users, :confirmation, token: "some_token")
      {:ok, _lv, html} = live(conn, test_url)
      assert html_has_title(html, "Confirm Your Account")
    end

    test "does not confirm a given token more than once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Users.deliver_user_confirmation_instructions(user, url)
        end)

      test_url = route(:users, :confirmation, token: token)

      # make initial request
      {:ok, lv, _html} = live(conn, test_url)

      # submit form data
      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, route(:users, :show))

      # form was submitted successfully
      assert {:ok, resp_conn} = result

      # response contains expected flash message
      assert conn_has_flash_message(resp_conn, :success, "Your account has been confirmed.")

      assert Users.get_user!(user.id).confirmed_at
      refute get_session(resp_conn, :user_token)
      assert Repo.all(Users.UserToken) == []

      # does not re-confirm when user is unauthenticated
      {:ok, lv, _html} = live(conn, test_url)

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert {:ok, resp_conn_2} = result

      assert conn_has_flash_message(
               resp_conn_2,
               :error,
               "User confirmation link is invalid or it has expired"
             )

      # does not re-confirm when user is authenticated
      {:ok, lv, _html} = build_conn() |> login_user(user) |> live(test_url)

      # submit the form and follow the redirect
      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, route(:users, :show))

      # form was submitted successfully
      assert {:ok, resp_conn_3} = result

      # response contains expected flash message
      assert conn_has_flash_message(
               resp_conn_3,
               :info,
               "Your account has already been confirmed."
             )
    end

    test "does not confirm email address if token is invalid", %{conn: conn, user: user} do
      test_url = route(:users, :confirmation, token: "invalid_token")

      # make request
      {:ok, lv, _html} = live(conn, test_url)

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
               "User confirmation link is invalid or it has expired"
             )

      # email address has not been confirmed
      refute Users.get_user!(user.id).confirmed_at
    end
  end
end
