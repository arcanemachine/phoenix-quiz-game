defmodule QuizGameWeb.Support.Atom do
  @moduledoc "This project's `Atom` helper functions."

  def to_human_friendly_string(atom) do
    Atom.to_string(atom) |> String.replace("_", " ") |> String.capitalize()
  end
end

defmodule QuizGameWeb.Support.Changeset do
  @moduledoc "This project's `Ecto.Changeset` helper functions."

  # @doc """
  #   Check if a changeset will have a given value after it has been validated.

  #   This function checks both changed and unchanged data, and preferentially returns the value
  #   in the changed data. Otherwise, it will return the existing data in the field.

  #   ## Examples

  #     iex> field_will_have_value?(changeset, :some_field, "some value")
  #     true

  #     iex> field_will_have_value?(changeset, :some_field, "nonexistent value")
  #     false
  # """
  # @spec field_will_have_value?(Ecto.Changeset.t(), atom(), any()) :: boolean()
  # def field_will_have_value?(changeset, field, value) do
  #   # changes have expected value, or field has expected value which will not be changed
  #   Map.get(changeset.changes, field) == value ||
  #     (Map.get(changeset.data, field) == value &&
  #        Enum.member?([value, nil], Map.get(changeset.changes, field)))
  # end

  @doc """
    Checks a changeset's changed and existing data for a given field, and returns the most
    up-to-date value.

    ## Examples

      iex> get_changed_or_existing_value(changeset, :field_with_data_in_changes)
      "changed value"

      iex> get_changed_or_existing_value(changeset, :field_with_no_data_in_changes)
      "data value"
  """
  @spec get_changed_or_existing_value(Ecto.Changeset.t(), atom()) :: any()
  def get_changed_or_existing_value(changeset, field) do
    Map.get(changeset.changes, field, Map.get(changeset.data, field))
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
