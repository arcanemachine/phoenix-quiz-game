defmodule QuizGameWeb.UserControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import QuizGame.UsersFixtures
  import QuizGameWeb.TestMacros

  setup do
    %{user: user_fixture()}
  end

  def delete_confirm_url(), do: ~p"/users/me/delete"

  describe "delete_confirm" do
    test_redirects_unauthenticated_user_to_login_route(delete_confirm_url())

    test "renders expected template", %{conn: conn, user: user} do
      response = conn |> login_user(user) |> get(delete_confirm_url())

      assert response |> html_response(200) |> Floki.find("h1") |> Floki.raw_html() =~
               "Delete Your Account"
    end
  end
end
