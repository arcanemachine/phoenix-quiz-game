defmodule QuizGameWeb.Users.ControllerTest do
  @moduledoc false

  use QuizGameWeb.ConnCase, async: true

  import Ecto.Query
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.Users
  import QuizGameWeb.Support.Router

  alias QuizGame.Repo
  alias QuizGame.Users.User

  # setup
  setup do
    %{user: user_fixture()}
  end

  describe "users :delete_confirm" do
    @user_delete_url route(:users, :delete_confirm)

    test_redirects_unauthenticated_user_to_login_route(@user_delete_url, "GET")

    test "renders expected template", %{conn: conn, user: user} do
      resp_conn = conn |> login_user(user) |> get(@user_delete_url)
      assert html_has_title(resp_conn.resp_body, "Delete Your Account")
    end
  end

  describe "users :delete" do
    @user_delete_url route(:users, :delete_confirm)

    test_redirects_unauthenticated_user_to_login_route(@user_delete_url, "POST")

    test "deletes expected user", %{conn: conn, user: user} do
      # get initial record count before deletion
      get_user_count = fn -> Repo.one(from u in "users", select: count(u.id)) end
      initial_record_count = get_user_count.()

      # make request
      resp_conn = conn |> login_user(user) |> post(@user_delete_url)

      # response contains expected flash message
      assert conn_has_flash_message(
               resp_conn,
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
