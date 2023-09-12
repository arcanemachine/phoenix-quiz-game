defmodule QuizGameWeb.Support.HTML do
  @moduledoc "This project's HTML-related helper functions."

  import Phoenix.HTML

  @doc """
  Placeholder content to use when a value is empty text or null.

  Accepts 2 parameters:
    - `value`: The value to be displayed
    - `default`: The content to display if the value is null or empty text (default: `Not set`)

  ## Examples

      iex> value_or_default("some value")
      "some value"

      iex> value_or_default(nil)
      "Not set"

      iex> value_or_default(nil, "N/A")
      "N/A"

      iex> value_or_default("")
      "Not set"

      iex> value_or_default("", "N/A")
      "N/A"
  """
  def value_or_default(val, default_text \\ "Not set")

  def value_or_default("", default_text) do
    value_or_default(nil, default_text)
  end

  def value_or_default(val, default_text) do
    val ||
      raw("<span class=\"italic\">#{default_text |> html_escape() |> safe_to_string()}</span>")
  end
end

defmodule QuizGameWeb.Support.HTML.Form do
  @moduledoc "This project's HTML form helpers."

  @doc "A wrapper script that checks if a form's CAPTCHA has been completed and is valid."
  @spec captcha_valid?(map()) :: boolean()
  def captcha_valid?(params) do
    # only check for captcha if captcha enabled
    if Application.get_env(:hcaptcha, :public_key) == false do
      # always return true if hcaptcha disabled
      true
    else
      # check if captcha string is present, then check if it is valid
      with false <- String.length(params["h-captcha-response"]) == 0,
           {:ok, _response} <- Hcaptcha.verify(params["h-captcha-response"]) do
        true
      else
        _ ->
          false
      end
    end
  end

  @doc """
  Creates options usable in a <.input type='select'> component.

  ## Examples

      iex> select_options_get_from_schema_and_field(QuizGame.Quizzes.Card, :format)
      [{"Multiple choice", :multiple_choice}, {"True or false", :true_or_false}]
  """
  @spec select_options_get_from_schema_and_field(any(), atom()) :: [{String.t(), atom()}]
  def select_options_get_from_schema_and_field(queryable, field) do
    Ecto.Enum.values(queryable, field)
    |> Enum.map(fn item ->
      {item |> QuizGameWeb.Support.Atom.to_human_friendly_string(), item}
    end)
  end
end
