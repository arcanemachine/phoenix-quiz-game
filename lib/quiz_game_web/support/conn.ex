defmodule QuizGameWeb.Support.Conn do
  @moduledoc "This project's custom conn helper functions."

  import Plug.Conn
  import Phoenix.Controller

  @typep conn :: %Plug.Conn{}

  @typedoc "A HTTP response body"
  @type resp_body :: String.t() | nil

  @doc """
    Return a HTTP text response with a given status code.

    ## Examples

      iex> text_response(conn, 401)
      iex> text_response(conn, 401, "You are not authorized to view this page.")
  """

  @spec text_response(conn, integer(), resp_body) :: any()
  def text_response(%Plug.Conn{} = conn, status, resp_body \\ nil) do
    resp_body = resp_body || Plug.Conn.Status.reason_phrase(status)

    conn
    |> put_status(status)
    |> text(resp_body)
    |> halt()
  end
end
