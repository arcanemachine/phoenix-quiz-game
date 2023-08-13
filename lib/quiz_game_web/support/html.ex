defmodule QuizGameWeb.Support.Html do
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
