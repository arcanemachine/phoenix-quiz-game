defmodule QuizGameWeb.UserConfirmationInstructionsLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, UsersFixtures}
  import QuizGameWeb.Support.Router

  alias QuizGame.{Repo, Users}

  @test_url route(:users, :confirmation_instructions)

  setup do
    %{user: user_fixture()}
  end

  describe "Resend confirmation template" do
    test "renders expected template", %{conn: conn} do
      {:ok, _lv, html} = live(conn, @test_url)
      assert html_has_title(html, "Resend Confirmation Email")
    end

    test "sends a new confirmation token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, @test_url)

      # submit the form
      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      # expected record has been created
      assert Repo.get_by!(Users.UserToken, user_id: user.id).context == "confirm"
    end

    test "does not send confirmation token if user has already confirmed their account", %{
      conn: conn,
      user: user
    } do
      # ensure that user's account is already confirmed
      Repo.update!(Users.User.confirm_changeset(user))

      # make initial request
      {:ok, lv, _html} = live(conn, @test_url)

      # submit the form
      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: user.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      # response contains same message as when valid form is submitted
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      # expected record has not been created
      refute Repo.get_by(Users.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @test_url)

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", user: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      # response contains same message as when valid form is submitted
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Users.UserToken) == []
    end
  end
end
