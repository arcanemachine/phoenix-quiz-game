defmodule QuizGameWeb.Assertions do
  @moduledoc "Assertions that are commonly used across tests"
  import Phoenix.ConnTest

  def template_has_title(conn, title) do
    html_response(conn, 200) |> Floki.find("h1") |> Floki.raw_html() =~ title
  end

  def template_contains_element(conn, selector) do
    element = html_response(conn, 200) |> Floki.find(selector)
    !Enum.empty?(element)
  end

  # def element_contains_content(conn, selector, content) do
  #   html_response(conn, 200) |> Floki.find(selector) |> Floki.raw_html() =~ content
  # end

  def form_has_errors(conn) do
    html_response(conn, 200)
    |> Floki.find(~s|[data-test-label="alert-form-errors"]|)
    |> Floki.raw_html() =~
      "Fix the errors in the form"
  end
end
