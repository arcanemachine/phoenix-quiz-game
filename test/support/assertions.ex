defmodule QuizGame.TestSupport.Assertions do
  @moduledoc "Assertions that are commonly used across multiple tests."

  @typep conn :: %Plug.Conn{}
  @typep flash_kind :: :info | :success | :warning | :error
  @typep link_option :: {:url, String.t()} | {:content, String.t()}

  @doc "Check if a conn has a given flash message."
  @spec conn_has_flash_message(conn, flash_kind, String.t()) :: boolean()
  def conn_has_flash_message(conn, kind, message) do
    Phoenix.Flash.get(conn.assigns.flash, kind) =~ message
  end

  @doc "Check if a specific HTML element has certain content."
  @spec html_element_has_content(String.t(), String.t(), [String.t() | list(String.t())]) ::
          boolean()
  def html_element_has_content(html, selector, contents) when is_list(contents) do
    # check each item in the list
    results =
      for content <- contents do
        html_element_has_content(html, selector, content)
      end

    # return false if any of the content values do not match
    if Enum.member?(results, false), do: false, else: true
  end

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

  @doc "Check if HTML has a form with errors."
  @spec html_form_has_errors(String.t()) :: boolean()
  def html_form_has_errors(html) do
    html
    |> Floki.find("[data-component-kind='alert-form-errors']")
    |> (Enum.empty?() |> Kernel.not())
  end

  @doc "Check all elements in a given HTML string for matching content."
  @spec html_has_content(String.t(), String.t()) :: boolean()
  def html_has_content(html, content) do
    html |> Floki.find(":fl-contains('#{content}')") |> (Enum.empty?() |> Kernel.not())
  end

  @doc "Check to see if an HTML string contains a given element."
  @spec html_has_element(String.t(), String.t()) :: boolean()
  def html_has_element(html, selector) do
    html |> Floki.find(selector) |> (Enum.empty?() |> Kernel.not())
  end

  @doc "Check if a specific HTML element has a given flash message."
  @spec html_has_flash_message(String.t(), flash_kind, String.t()) :: boolean()
  def html_has_flash_message(html, kind, message) do
    html
    |> Floki.find("#flash-#{kind}")
    |> Floki.find(":fl-contains('#{message}')")
    |> (Enum.empty?() |> Kernel.not())
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

  @doc "Check if an HTML string has a given title (ie. content wrapped in a `<h1>` tag)."
  @spec html_has_title(String.t(), String.t()) :: boolean()
  def html_has_title(html, title) do
    html |> Floki.find("h1") |> Floki.raw_html() =~ title
  end
end
