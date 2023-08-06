defmodule QuizGame.TestSupport.Assertions do
  @moduledoc "Assertions that are commonly used across multiple tests."

  # import Phoenix.ConnTest
  # import Phoenix.LiveViewTest

  @typep conn :: %Plug.Conn{}
  @typep flash_kind :: :info | :success | :warning | :error
  @typep link_option :: {:url, String.t()} | {:content, String.t()}

  @doc "Check if a conn has a given flash message."
  @spec conn_has_flash_message(conn, flash_kind, String.t()) :: boolean()
  def conn_has_flash_message(conn, kind, message) do
    Phoenix.Flash.get(conn.assigns.flash, kind) =~ message
  end

  @doc "Check a specific HTML element for matching content."
  @spec html_element_has_content(String.t(), String.t(), String.t()) :: boolean()
  def html_element_has_content(html, selector, content) do
    html
    |> Floki.find(selector)
    |> Floki.find(":fl-contains('#{content}')")
    |> (Enum.empty?() |> Kernel.not())
  end

  @doc "Check if a form field has a given error message."
  @spec html_form_field_has_error_message(String.t(), String.t(), String.t()) :: boolean()
  def html_form_field_has_error_message(html, field_name, message) do
    html
    |> Floki.find("[phx-feedback-for='#{field_name}']")
    |> Floki.find(":fl-contains('#{message}')")
    |> (Enum.empty?() |> Kernel.not())
  end

  @doc "Check all elements in a given HTML string for matching content."
  @spec html_has_content(String.t(), String.t()) :: boolean()
  def html_has_content(html, content) do
    html |> Floki.find(":fl-contains('#{content}')") |> (Enum.empty?() |> Kernel.not())
  end

  @doc """
  Check if HTML has a link with a given content and/or URL.

  Accepts one or more of the following options: 'content', 'url'

  ## Examples

      iex> html_has_link(html, url: "/", content: "Hello world!")
  """
  @spec html_has_link(String.t(), [link_option()]) :: boolean()
  def html_has_link(html, opts \\ []) when length(opts) > 0 do
    maybe_url = (opts[:url] && "[href='#{opts[:url]}']") || "*"
    maybe_content = (opts[:content] && ":fl-contains('#{opts[:content]}')") || "*"

    html
    |> Floki.find("a")
    |> Floki.find(maybe_url)
    |> Floki.find(maybe_content)
    |> (Enum.empty?() |> Kernel.not())
  end

  @spec html_has_title(String.t(), String.t()) :: boolean()
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

  # def html_response_has_title(conn, title) do
  #   html_response(conn, 200) |> html_has_title(title)
  # end

  # def html_response_has_form_errors(conn) do
  #   html_response(conn, 200)
  #   |> Floki.find(~s|[data-test-label="alert-form-errors"]|)
  #   |> Floki.raw_html() =~ "Fix the errors in the form"
  # end

  # def live_element_has_text(lv, selector, text) do
  #   lv |> element(selector) |> render() =~ text
  # end

  # def live_view_has_title(lv, title) do
  #   lv |> element("h1") |> render() =~ title
  # end
end
