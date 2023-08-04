defmodule QuizGameWeb.UserControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import Ecto.Query
  import QuizGame.UsersFixtures
  import QuizGameWeb.TestSupport.GenericTests

  alias QuizGame.Repo
  alias QuizGame.Users.User

  # data
  @url_delete_confirm "/users/me/delete"
  @url_delete "/users/me/delete"

  # setup
  setup do
    %{user: user_fixture()}
  end

  describe "users :delete_confirm" do
    @test_url @url_delete_confirm

    test_redirects_unauthenticated_user_to_login_route(@test_url, "GET")

    test "renders expected template", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> get(@test_url)

      assert conn |> html_response(200) |> Floki.find("h1") |> Floki.raw_html() =~
               "Delete Your Account"
    end
  end

  describe "users :delete" do
    test_redirects_unauthenticated_user_to_login_route(@url_delete, "POST")

    test "deletes expected user", %{conn: conn, user: user} do
      get_user_count = fn -> Repo.one(from u in "users", select: count(u.id)) end

      # get initial object count before deletion
      initial_object_count = get_user_count.()

      # make request
      conn = conn |> login_user(user) |> post(@url_delete_confirm)

      # response contains expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~
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
