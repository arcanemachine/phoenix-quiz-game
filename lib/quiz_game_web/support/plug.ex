defmodule QuizGameWeb.Support.Plug do
  @moduledoc "This project's custom function plugs."
  use QuizGameWeb, :controller

  alias QuizGameWeb.Support.Conn, as: ProjectConn

  @doc "Return a 404 response if a given param cannot be converted to an integer."
  def ensure_param_is_number(conn, param) do
    try do
      String.to_integer(param) && conn
    rescue
      _ in ArgumentError -> conn |> ProjectConn.text_response(404)
    end
  end

  @doc """
  Get a Quiz by the `quiz_id` param and add it to `conn.assigns`.
  """
  def fetch_quiz(conn, _opts) do
    conn
    |> ensure_param_is_number(conn.params["quiz_id"])
    |> assign(:quiz, QuizGame.Quizzes.get_quiz!(conn.params["quiz_id"]))
  end

  @doc """
  If a non-root URL ends with a slash '/', do a permanent redirect to a URL that removes it.
  """
  def remove_trailing_slash(conn, _opts) do
    if conn.request_path != "/" && String.last(conn.request_path) == "/" do
      # return a permanent redirect to a URL without the trailing slash, and
      # halt the current request
      conn
      |> put_status(301)
      |> redirect(to: String.slice(conn.request_path, 0..-2//1))
      |> halt()
    else
      conn
    end
  end
end
