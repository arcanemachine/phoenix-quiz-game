defmodule QuizGameWeb.UserControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import Ecto.Query
  import QuizGame.TestSupport.{Assertions, GenericTests, UsersFixtures}
  import QuizGameWeb.Support.Router

  alias QuizGame.Repo
  alias QuizGame.Users.User

  # setup
  setup do
    %{user: user_fixture()}
  end

  describe "users :delete_confirm" do
    @test_url_path route(:users, :delete_confirm)

    test_redirects_unauthenticated_user_to_login_route(@test_url_path, "GET")

    test "renders expected template", %{conn: conn, user: user} do
      response_conn = conn |> login_user(user) |> get(@test_url_path)
      assert html_response_has_title(response_conn, "Delete Your Account")
    end
  end

  describe "users :delete" do
    @test_url_path route(:users, :delete_confirm)

    test_redirects_unauthenticated_user_to_login_route(@test_url_path, "POST")

    test "deletes expected user", %{conn: conn, user: user} do
      # get initial record count before deletion
      get_user_count = fn -> Repo.one(from u in "users", select: count(u.id)) end
      initial_record_count = get_user_count.()

      # make request
      response_conn = conn |> login_user(user) |> post(@test_url_path)

      # response contains expected flash message
      assert html_response_has_flash_message(
               response_conn,
               :success,
               "Account deleted successfully"
             )

      # expected record has been deleted
      assert_raise Ecto.NoResultsError, fn ->
        Repo.get!(User, user.id)
      end

      # record count has decreased by one
      assert get_user_count.() == initial_record_count - 1
    end
  end
end
