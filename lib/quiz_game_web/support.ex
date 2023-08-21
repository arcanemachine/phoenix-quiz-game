defmodule QuizGameWeb.Support do
  @moduledoc "This project's web-related helper functions."

  @doc """
    If a given query returns a record, then return it. Otherwise, raise an exception that returns
    a 404 response.

    ## Examples

      iex> get_record_or_404(query)
      %User{}

      iex> get_record_or_404(empty_query)
      ** (Ecto.NoResultsError)
  """
  def get_record_or_404(query) do
    if record = QuizGame.Repo.one!(query) do
      record
    else
      raise Ecto.NoResultsError, queryable: query
    end
  end

  @doc "A wrapper script that checks if a form's CAPTCHA has been completed, and is valid."
  @spec form_captcha_valid?(map()) :: boolean()
  def form_captcha_valid?(params) do
    # only check for captcha if captcha enabled
    if Application.get_env(:hcaptcha, :public_key) == false do
      # always return true if hcaptcha disabled
      true
    else
      # check if captcha string is present, then check if it is valid
      with false <- String.length(params["h-captcha-response"]) == 0,
           {:ok, _response} <- Hcaptcha.verify(params["h-captcha-response"]) do
        true
      else
        _ ->
          false
      end
    end
  end

  @doc "Convert URL params to a keyword list."
  @spec params_to_keyword_list(map()) :: keyword()
  def params_to_keyword_list(params) do
    params |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end
end

defmodule QuizGameWeb.Support.Atom do
  @moduledoc "This project's atom-related helper functions."

  def to_human_friendly_string(atom) do
    Atom.to_string(atom) |> String.replace("_", " ") |> String.capitalize()
  end
end

defmodule QuizGameWeb.Support.Conn do
  @moduledoc "This project's conn helper functions."

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

defmodule QuizGameWeb.Support.HTML do
  @moduledoc "This project's HTML helpers."

  import Phoenix.HTML

  @doc """
  Placeholder content for null record values.

  Accepts a single optional argument `content` which contains the content to be displayed in the
  template.
    - Default: "Not set"

  ## Examples

      iex> null_value_content()
      iex> null_value_content("some content")
  """
  def null_value_content(content \\ "Not set") do
    raw("<span class=\"italic\">#{content |> html_escape() |> safe_to_string()}</span>")
  end
end
