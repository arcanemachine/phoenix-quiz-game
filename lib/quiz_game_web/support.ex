defmodule QuizGameWeb.Support.Atom do
  @moduledoc "This project's `Atom` helper functions."

  def to_human_friendly_string(atom) do
    Atom.to_string(atom) |> String.replace("_", " ") |> String.capitalize()
  end
end

defmodule QuizGameWeb.Support.Conn do
  @moduledoc "This project's `Plug.Conn` helper functions."

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

defmodule QuizGameWeb.Support.Map do
  @moduledoc "This project's `Map` helper functions."

  @doc """
  Convert URL params to a keyword list.

  ## Examples

      iex> params_to_keyword_list(%{"hello" => "world"})
      [{:hello, "world"}]
  """
  @spec params_to_keyword_list(map()) :: keyword()
  def params_to_keyword_list(params) do
    params |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end
end

defmodule QuizGameWeb.Support.Repo do
  @moduledoc "This project's `Ecto.Repo` helper functions."

  @doc """
    If a given query returns a record, then return it. Otherwise, raise an exception that returns
    a 404 response.

    ## Examples

      iex> record_get_or_404(query)
      %User{}

      iex> record_get_or_404(empty_query)
      ** (Ecto.NoResultsError)
  """
  def record_get_or_404(query) do
    if record = QuizGame.Repo.one!(query) do
      record
    else
      raise Ecto.NoResultsError, queryable: query
    end
  end
end
