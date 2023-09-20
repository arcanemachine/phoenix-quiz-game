defmodule QuizGameWeb.Quizzes.Record.Controller do
  @moduledoc false
  use QuizGameWeb, :controller

  import Ecto.Query

  alias QuizGame.Quizzes.{Quiz, Record}
  alias QuizGame.Repo

  def index(conn, %{"quiz_id" => quiz_id} = _params) do
    quiz = Repo.one!(from q in Quiz, where: q.id == ^quiz_id)
    records = Repo.all(from r in Record, where: r.quiz_id == ^quiz_id, preload: [:user])

    render(conn, :index,
      page_title: "Quiz Records",
      page_subtitle: quiz.name,
      quiz: quiz,
      records: records
    )
  end
end
