defmodule QuizGameWeb.TestSupport.Assertions do
  @moduledoc "Assertions that are commonly used across tests"
  import Phoenix.ConnTest

  # def html_response_has_element(conn, selector) do
  #   element = html_response(conn, 200) |> Floki.find(selector)
  #   !Enum.empty?(element)
  # end

  def html_response_has_flash_message(conn, kind, message) do
    Phoenix.Flash.get(conn.assigns.flash, kind) =~ message
  end

  def html_response_has_text(conn, text) do
    html_response(conn, 200) =~ text
  end

  def html_response_has_title(conn, title) do
    html_response(conn, 200) |> Floki.find("h1") |> Floki.raw_html() =~ title
  end

  # def response_element_has_text(conn, selector, text) do
  #   html_response(conn, 200) |> Floki.find(selector) |> Floki.raw_html() =~ text
  # end

  # def html_response_has_form_errors(conn) do
  #   html_response(conn, 200)
  #   |> Floki.find(~s|[data-test-label="alert-form-errors"]|)
  #   |> Floki.raw_html() =~ "Fix the errors in the form"
  # end
end
