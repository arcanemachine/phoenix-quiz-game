defmodule QuizGameWeb.UserControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import Ecto.Query
  import QuizGame.UsersFixtures
  import QuizGameWeb.TestMacros

  alias QuizGame.Repo
  alias QuizGame.Users.User

  setup do
    %{user: user_fixture()}
  end

  def delete_confirm_url(), do: ~p"/users/me/delete"
  def delete_url(), do: ~p"/users/me/delete"

  describe "delete_confirm" do
    test_redirects_unauthenticated_user_to_login_route(delete_confirm_url(), "GET")

    test "renders expected template", %{conn: conn, user: user} do
      response_conn = conn |> login_user(user) |> get(delete_confirm_url())

      assert response_conn |> html_response(200) |> Floki.find("h1") |> Floki.raw_html() =~
               "Delete Your Account"
    end
  end

  describe "delete" do
    test_redirects_unauthenticated_user_to_login_route(delete_url(), "POST")

    test "deletes expected user", %{conn: conn, user: user} do
      get_user_count = fn -> Repo.one(from u in "users", select: count(u.id)) end

      # get initial object count before deletion
      initial_object_count = get_user_count.()

      # make request
      response_conn = conn |> login_user(user) |> post(delete_confirm_url())

      # response contains expected flash message
      assert Phoenix.Flash.get(response_conn.assigns.flash, :success) =~
               "Account deleted successfully"

      # expected object has been deleted
      assert_raise Ecto.NoResultsError, fn ->
        Repo.get!(User, user.id)
      end

      # object count has decreased by one
      assert get_user_count.() == initial_object_count - 1
    end
  end
end
