defmodule QuizGameWeb.Support.HTML do
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
