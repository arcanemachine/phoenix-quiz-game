defmodule QuizGameWeb.Support.Plug do
  @moduledoc "This project's custom function plugs."
  use QuizGameWeb, :controller

  alias QuizGameWeb.Support.Conn, as: ProjectConn

  @typep conn :: %Plug.Conn{}

  @doc "Return a 404 response if a given param cannot be converted to an integer."
  @spec ensure_param_is_number(conn, String.t()) :: conn
  def ensure_param_is_number(conn, param) do
    try do
      _ = String.to_integer(param)
      conn
    rescue
      _ in ArgumentError -> conn |> ProjectConn.text_response(404)
    end
  end

  @doc "Get a Quiz by the param `quiz_id` and add it to `conn.assigns`."
  @spec fetch_quiz(conn, keyword()) :: conn
  def fetch_quiz(conn, _opts) do
    conn
    |> ensure_param_is_number(conn.params["quiz_id"])
    |> assign(:quiz, QuizGame.Quizzes.get_quiz!(conn.params["quiz_id"]))
  end

  @doc """
  If a non-root URL ends with a forward slash (`/`), then do a permanent redirect to a URL that
  removes that slash.
  """
  @spec fetch_quiz(conn, keyword()) :: conn
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
