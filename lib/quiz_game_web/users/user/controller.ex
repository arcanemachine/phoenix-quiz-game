defmodule QuizGameWeb.Users.User.Controller do
  @moduledoc false

  use QuizGameWeb, :controller

  import Ecto.Query

  alias QuizGame.{Repo, Users}
  alias QuizGame.Quizzes.{Quiz, Record}
  alias QuizGameWeb.UserAuth

  # user
  def show(conn, _params) do
    render(conn, :show, page_title: "Your Profile")
  end

  def settings(conn, _params) do
    conn |> render(:settings, page_title: "Manage Your Account")
  end

  def delete_confirm(conn, _params) do
    render(conn, :delete_confirm, page_title: "Delete Your Account")
  end

  def delete(conn, _params) do
    Users.delete_user(conn.assigns[:current_user])

    conn
    |> put_flash(:success, "Account deleted successfully")
    |> UserAuth.logout_user()
  end

  # related objects
  def quizzes_index(conn, _params) do
    query = from q in Quiz, where: q.user_id == ^conn.assigns.current_user.id
    quizzes = Repo.all(query)

    render(conn, :quizzes_index, page_title: "Your Quizzes", quizzes: quizzes)
  end

  def records_index(conn, _params) do
    query =
      from q in Record,
        where: q.user_id == ^conn.assigns.current_user.id,
        order_by: [{:desc, :inserted_at}],
        preload: :quiz

    records = Repo.all(query)

    render(conn, :records_index,
      page_title: "Your Quiz Records",
      records: records
    )
  end
end
