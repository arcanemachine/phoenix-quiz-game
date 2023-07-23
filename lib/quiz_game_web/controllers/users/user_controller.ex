defmodule QuizGameWeb.UserController do
  use QuizGameWeb, :controller

  alias QuizGame.Users
  alias QuizGameWeb.UserAuth

  def delete_confirm(conn, _params) do
    render(conn, :delete_confirm, page_title: "Delete Your Account")
  end

  def delete(conn, _params) do
    # get user
    user = conn.assigns[:current_user]

    # delete the user
    Users.delete_user(user)

    # queue success message and log the user out
    conn
    |> put_flash(:success, "Account deleted successfully")
    |> UserAuth.logout_user()
  end
end
