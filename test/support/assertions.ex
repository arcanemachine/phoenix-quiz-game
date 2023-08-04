defmodule QuizGameWeb.Assertions do
  @moduledoc "Assertions that are commonly used across tests"
  import Phoenix.ConnTest

  def response_template_has_title(conn, title) do
    html_response(conn, 200) |> Floki.find("h1") |> Floki.raw_html() =~ title
  end

  def response_template_has_text(conn, text) do
    html_response(conn, 200) =~ text
  end

  def response_template_has_element(conn, selector) do
    element = html_response(conn, 200) |> Floki.find(selector)
    !Enum.empty?(element)
  end

  # def element_contains_text(conn, selector, text) do
  #   html_response(conn, 200) |> Floki.find(selector) |> Floki.raw_html() =~ text
  # end

  def form_has_errors(conn) do
    html_response(conn, 200)
    |> Floki.find(~s|[data-test-label="alert-form-errors"]|)
    |> Floki.raw_html() =~ "Fix the errors in the form"
  end
end
