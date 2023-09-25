defmodule QuizGameWeb.Users.User.Live.UpdateDisplayNameTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.Users

  alias QuizGame.Users

  describe "UpdateDisplayName page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} =
        conn |> login_user(user_fixture()) |> live(~p"/users/me/update/display-name")

      assert html_has_title(html, "Update Display Name")
    end

    test_redirects_unauthenticated_user_to_login_route(~p"/users/me/update/display-name", "GET")
  end

  describe "UpdateDisplayName form" do
    setup %{conn: conn} do
      # register and login a user
      user = user_fixture()

      %{conn: login_user(conn, user), user: user}
    end

    test "updates the user's display_name", %{conn: conn, user: user} do
      updated_display_name = "updated display name"

      # make initial request
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/display-name")

      # build valid form data
      form_data = %{"user[display_name]" => updated_display_name}

      # submit the form and follow the redirect
      form = form(lv, "#user-update-display-name-form", form_data)
      render_submit(form)

      # view redirects to expected route and has expected flash message(s)
      flash = assert_redirect(lv, ~p"/users/me/update")
      assert flash == %{"success" => "Display name updated successfully"}

      # record has been updated with expected value
      updated_user = Users.get_user!(user.id)
      assert updated_user.display_name == updated_display_name
    end

    test "updates the user's display_name (with '?next=' URL param)", %{conn: conn, user: user} do
      updated_display_name = "updated display name"
      next_url_path = "/some-next-url/"

      # make initial request
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/display-name?#{%{next: next_url_path}}")

      # build valid form data
      form_data = %{"user[display_name]" => updated_display_name}

      # submit the form and follow the redirect
      form = form(lv, "#user-update-display-name-form", form_data)
      render_submit(form)

      # view redirects to expected route and has expected flash message(s)
      flash = assert_redirect(lv, next_url_path)
      assert flash == %{"success" => "Display name updated successfully"}

      # record has been updated with expected value
      updated_user = Users.get_user!(user.id)
      assert updated_user.display_name == updated_display_name
    end

    test "renders expected errors on 'change' event when form data is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/display-name")

      html_after_change =
        lv
        |> element("#user-update-display-name-form")
        |> render_change(%{"user[display_name]" => ""})

      # still on the same page
      assert html_has_title(html_after_change, "Update Display Name")

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_change,
               "user[display_name]",
               "is required"
             )
    end

    test "renders expected errors on 'submit' event when form data is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/me/update/display-name")

      # submit the form
      html_after_submit =
        lv
        |> form("#user-update-display-name-form", %{
          "user" => %{"display_name" => ""}
        })
        |> render_submit()

      # still on the same page due to form error(s)
      assert html_has_title(html_after_submit, "Update Display Name")

      # form has expected error message(s)
      assert html_form_field_has_error_message(
               html_after_submit,
               "user[display_name]",
               "is required"
             )
    end
  end
end
