defmodule QuizGameWeb.Support.Plug do
  @moduledoc """
  This project's custom function plugs.
  """

  use QuizGameWeb, :controller

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
