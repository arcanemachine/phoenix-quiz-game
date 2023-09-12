defmodule QuizGameWeb.Support.Atom do
  @moduledoc "This project's `Atom`-related helper functions."

  def to_human_friendly_string(atom) do
    Atom.to_string(atom) |> String.replace("_", " ") |> String.capitalize()
  end
end

defmodule QuizGameWeb.Support.Changeset do
  @moduledoc "This project's `Ecto.Changeset`-related helper functions."

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
  @moduledoc "This project's `Plug.Conn`-related helper functions."

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

defmodule QuizGameWeb.Support.Ecto do
  @moduledoc "This project's `Ecto`-related helper functions."

  @doc """
    Returns a list of options for a given `Ecto.Enum` field.

    ## Examples

      iex> get_enum_field_options(Card, :format)
      [:multiple_choice, :number_entry, :text_entry, :true_or_false]
  """
  @spec get_enum_field_options(module(), atom()) :: list()
  def get_enum_field_options(module, field) do
    Ecto.Enum.mappings(module, field) |> Keyword.keys()
  end
end

defmodule QuizGameWeb.Support.Exceptions.HttpResponse do
  @moduledoc "Returns a HTTP response."
  defexception [:plug_status, :message]

  def exception(opts) do
    %__MODULE__{
      plug_status: opts[:plug_status],
      message: opts[:message] || Plug.Conn.Status.reason_phrase(opts[:plug_status])
    }
  end
end

defmodule QuizGameWeb.Support.Map do
  @moduledoc "This project's `Map`-related helper functions."

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

defmodule QuizGameWeb.Support.String do
  @moduledoc "This project's `String`-related helper functions."

  @doc """
  Pluralizes a value based on the length of the given inputs.

  Optionally use custom values for pluralized name. Defaults to `val` + 's'.

  ## Examples

      iex> pluralize("word", 1)
      "word"

      iex> pluralize("word", 2)
      "words"

      iex> pluralize("cherry", 2, "cherries")
      "cherries"
  """
  @spec pluralize(String.t(), integer(), String.t() | nil) :: String.t()

  def pluralize(word, count, plural_word \\ nil) do
    if count == 1 do
      word
    else
      if plural_word do
        plural_word
      else
        word <> "s"
      end
    end
  end

  @doc """
  Capitalizes the first letter of each word in a string.

  ## Examples

      iex> titlecase("hello world")
      "Hello World"
  """
  def titlecase(val) do
    String.split(val, " ") |> Enum.map_join(" ", fn word -> String.capitalize(word) end)
  end
end
