defmodule QuizGameWeb.Conn do
  @moduledoc "This project's custom conn helper functions."

  import Plug.Conn
  import Phoenix.Controller

  @type conn :: %Plug.Conn{}

  @typedoc "The HTTP status of the response, e.g. :ok | 200"
  @type status :: atom() | integer()

  @typedoc "The HTTP response body"
  @type resp_body :: String.t() | nil

  @doc """
    Return a HTTP text response.

    ## Examples

      iex> text_response(conn, :unauthorized)
      iex> text_response(conn, :unauthorized, "You are not authorized to view this page.")
      iex> text_response(conn, 401)
      iex> text_response(conn, 401, "You are not authorized to view this page.")
  """

  @spec text_response(conn, status, resp_body) :: any()
  def text_response(%Plug.Conn{} = conn, status, resp_body \\ nil) do
    resp_body = resp_body || "#{status}"

    conn
    |> put_status(status)
    |> text(resp_body)
    |> halt()
  end
end