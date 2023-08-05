defmodule QuizGameWeb.TestSupport.Assertions do
  @moduledoc "Assertions that are commonly used across multiple tests."
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  def html_element_has_text(html, selector, text) do
    html |> Floki.find(selector) |> Floki.raw_html() =~ text
  end

  def html_form_field_has_error_message(html, field_name, message) do
    html |> Floki.find("[phx-feedback-for='#{field_name}']") |> Floki.raw_html() =~ message
  end

  def html_has_text(html, text) do
    html =~ text
  end

  def html_has_title(html, title) do
    html |> Floki.find("h1") |> Floki.raw_html() =~ title
  end

  # def html_response_element_has_text(conn, selector, text) do
  #   html_response(conn, 200) |> Floki.find(selector) |> Floki.raw_html() =~ text
  # end

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
    html_response(conn, 200) |> html_has_title(title)
  end

  # def html_response_has_form_errors(conn) do
  #   html_response(conn, 200)
  #   |> Floki.find(~s|[data-test-label="alert-form-errors"]|)
  #   |> Floki.raw_html() =~ "Fix the errors in the form"
  # end

  # def live_element_has_text(lv, selector, text) do
  #   lv |> element(selector) |> render() =~ text
  # end

  def live_view_has_title(lv, title) do
    lv |> element("h1") |> render() =~ title
  end
end
