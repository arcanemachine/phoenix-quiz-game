defmodule QuizGameWeb.Support.Atom do
  @moduledoc "This project's `Atom` helper functions."

  def to_human_friendly_string(atom) do
    Atom.to_string(atom) |> String.replace("_", " ") |> String.capitalize()
  end
end

defmodule QuizGameWeb.Support.Changeset do
  @moduledoc "This project's `Ecto.Changeset` helper functions."

  @doc """
    Check if a changeset will have a given value after it is validated.

    ## Examples

      iex> changeset_field_will_have_value(changeset, :field_name, "some value")
      true

      iex> changeset_field_will_have_value(changeset, :field_name, "nonexistent value")
      false
  """
  @spec field_will_have_value(Ecto.Changeset.t(), atom(), any()) :: boolean()
  def field_will_have_value(changeset, field, value) do
    # field has expected value which will not be changed, or changes have expected value
    (Map.get(changeset.data, field) == value && !(Map.get(changeset.changes, field) != value)) ||
      Map.get(changeset.changes, field) == value
  end

  # @spec field_will_not_have_value(Ecto.Changeset.t(), atom(), any()) :: boolean()
  # def field_will_not_have_value(changeset, field, value) do
  #   # field has expected value which will be changed, or changes do not have expected value
  #   (Map.get(changeset.data, field) == value && Map.get(changeset.changes, field) != value) ||
  #     Map.get(changeset.changes, field) != value
  # end

  @doc """
    Checks a changeset's changed and existing data for a given field, and returns the most
    up-to-date value.

    ## Examples

      iex> get_changed_or_existing_value(changeset, :field_name)
      "some value"
  """
  @spec get_changed_or_existing_value(Ecto.Changeset.t(), atom(), keyword()) :: any()
  def get_changed_or_existing_value(changeset, field, opts \\ []) do
    Map.get(changeset.changes, field) || Map.get(changeset.data, field)
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
