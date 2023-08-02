defmodule QuizGameWeb.UserControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import QuizGame.UsersFixtures

  setup do
    %{user: user_fixture()}
  end

  @tag fixme: true
  describe "delete_confirm" do
    def test_url, do: ~p"/users/me/delete"

    test "renders expected template", %{conn: conn, user: user} do
      response = conn |> login_user(user) |> get(test_url())

      assert response |> html_response(200) |> Floki.find("h1") |> Floki.raw_html() =~
               "Delete Your Account"
    end
  end
end
